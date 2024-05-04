import pandas as pd
import numpy as np
import re
import matplotlib.pyplot as plt
import optuna

from sklearn.preprocessing import LabelEncoder, StandardScaler, MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score, mean_squared_error
from sklearn.model_selection import train_test_split, GridSearchCV
from catboost import CatBoostRegressor
from lightgbm import LGBMRegressor
from xgboost import XGBRegressor

x_data = pd.read_csv('X.csv')
y_data = pd.read_csv('Y.csv')

x_codes = x_data['유치원코드'].unique()
y_codes = y_data['유치원코드'].unique()

x_data.fillna(0, inplace=True)
y_data.fillna(0, inplace=True)

df = pd.concat([x_data, y_data])

def extract_sum(string):
    numbers = re.findall(r'\d+', string)
    return sum(map(int, numbers))

df['건물층수'] = df['건물층수'].apply(extract_sum)

def remove_len(string):
    return ''.join(re.findall(r'\d+', string))

df['건물전용면적'] = df['건물전용면적'].apply(remove_len)
df['대지총면적'] = df['대지총면적'].apply(remove_len)

lab_encoder = LabelEncoder()
df['설립유형'] = lab_encoder.fit_transform(df['설립유형'])

not_encoding = ['설립유형',  '특수교사수', '유치원코드', '교육지원청명']
minmax_encoding = ['건물전용면적', '대지총면적']
all_columns = df.columns.tolist()
std_encoding = [col for col in all_columns if col not in not_encoding + minmax_encoding]

df[minmax_encoding] = df[minmax_encoding].astype(float)

std_scaler = StandardScaler()
df[std_encoding] = std_scaler.fit_transform(df[std_encoding])

df[minmax_encoding] = np.log1p(df[minmax_encoding])
minmax_scaler = MinMaxScaler()
df[minmax_encoding] = minmax_scaler.fit_transform(df[minmax_encoding])

X = df[df['유치원코드'].isin(x_codes)]
Pred = df[df['유치원코드'].isin(y_codes)]

key = Pred['유치원코드']
y = X['특수교사수']
Pred = Pred.drop(['특수교사수', '유치원코드', '교육지원청명'], axis=1)
X = X.drop(['특수교사수', '유치원코드', '교육지원청명'], axis=1)

X_train, X_valid, y_train, y_valid = train_test_split(X,y,test_size=0.2,random_state=42)

xgb = XGBRegressor()
cb = CatBoostRegressor()
lg = LGBMRegressor()

xgb.fit(X_train, y_train)
cb.fit(X_train, y_train)
lg.fit(X_train, y_train)

y_pred_xgb = xgb.predict(X_valid)
y_pred_cb = cb.predict(X_valid)
y_pred_lg = lg.predict(X_valid)

rmse_xgb = np.sqrt(mean_squared_error(y_valid, y_pred_xgb))
rmse_cb = np.sqrt(mean_squared_error(y_valid, y_pred_cb))
rmse_lg = np.sqrt(mean_squared_error(y_valid, y_pred_lg))

r2_xgb = r2_score(y_valid, y_pred_xgb)
r2_cb = r2_score(y_valid, y_pred_cb)
r2_lg = r2_score(y_valid, y_pred_lg)

print("XGBoost RMSE:", rmse_xgb, "R^2:", r2_xgb)
print("CatBoost RMSE:", rmse_cb, "R^2:", r2_cb)
print("LightGBM RMSE:", rmse_lg, "R^2:", r2_lg)

def objective(trial):
    params = {
        'iterations': trial.suggest_int('iterations', 100, 1000),
        'depth': trial.suggest_int('depth', 4, 10),
        'learning_rate': trial.suggest_float('learning_rate', 0.01, 0.3, log=True),
        'random_strength': trial.suggest_int('random_strength', 0, 100),
        'bagging_temperature': trial.suggest_float('bagging_temperature', 0.0, 1.0),
        'l2_leaf_reg': trial.suggest_float('l2_leaf_reg', 1e-8, 10.0, log=True),
        'border_count': trial.suggest_int('border_count', 1, 255),
    }

    model = CatBoostRegressor(**params, loss_function='RMSE', verbose=False)
    model.fit(X_train, y_train, eval_set=[(X_valid, y_valid)], early_stopping_rounds=100)

    preds = model.predict(X_valid)
    rmse = mean_squared_error(y_valid, preds, squared=False)

    return rmse

study = optuna.create_study(direction='minimize')
study.optimize(objective, n_trials=100, gc_after_trial=True)

best_params = study.best_params
best_params['loss_function'] = 'RMSE'
best_params['verbose'] = False

optimized_model = CatBoostRegressor(**best_params)
optimized_model.fit(X_train, y_train, eval_set=[(X_valid, y_valid)], early_stopping_rounds=100, verbose=False)

preds = optimized_model.predict(X_valid)

rmse = mean_squared_error(y_valid, preds, squared=False)
print(f"Optimized CatBoost RMSE: {rmse}")

rs = optimized_model.predict(Pred)

rs = np.round(rs).astype(int)

result = pd.DataFrame()
result['유치원코드'] = key
result['특수교사수_추천'] = rs

def join(df1, df2, using, type):
    merged = pd.merge(df1, df2, on=using, how=type, suffixes=('', ''))
    return merged

full_rs = join(y_data, result, '유치원코드', 'inner')

full_rs['특수교사수증감폭'] = full_rs['특수교사수_추천'] - full_rs['특수교사수']

full_rs.to_csv('예측결과.csv', index=False)