import sys 
import numpy as np
import xgboost as xgb 
import AUC as auc 

dtrain=xgb.DMatrix('/home/wangke/log/features_with_index/data2')
dtest = xgb.DMatrix('/home/wangke/log/features_with_index/part-00888')

#param = {'max_depth':2,'lambda':0.01,'alpha':0.14, 'eta':0.35, 'silent':1, 'objective':'binary:logistic'}
param = {'max_depth':2,'lambda':0.01,'alpha':0.14, 'eta':0.30, 'silent':1, 'objective':'binary:logistic'}


#watchlist  = [(dtest,'test'), (dtrain,'train')]
num_round = 110 
#num_round = 120
#bst = xgb.train(param, dtrain, num_round, watchlist)


res = xgb.cv(param, dtrain, num_boost_round=110, nfold=5,
             metrics={'error','auc'}, seed = 0)
print (res) 
#preds = bst.predict(dtest)
#labels = dtest.get_label()

#auc_value = auc.scoreAUC(labels,preds)
#print auc_value

