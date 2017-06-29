import sys
import numpy as np
import xgboost as xgb

dtrain = xgb.DMatrix('/home/wangke/log/features_with_index/train')

#dtest = xgb.DMatrix('./feature_svm_file/Test.data')
dtest = xgb.DMatrix('/home/wangke/log/features_with_index/test')
#param = {'max_depth':2,'lambda':0.02,'alpha':0.16, 'eta':0.35, 'silent':1, 'objective':'binary:logistic','eval_metric':['error','auc']}
num_round=sys.argv[1]#300
lambda2=sys.argv[2]#0.02
alpha=sys.argv[3]#0.14
eta=sys.argv[4]#0.3

param = {'max_depth':2,'lambda':lambda2,'alpha':alpha, 'eta':eta, 'silent':1, 'objective':'binary:logistic','eval_metric':['error','auc']}

watchlist  = [(dtest,'test'), (dtrain,'train')]
bst = xgb.train(param, dtrain, int(num_round), watchlist)


#watchlist  = [(dtest,'test'), (dtrain,'train')]
#num_round = 
#bst = xgb.train(param, dtrain, num_round, watchlist)
#res = xgb.cv(param, dtrain, nfold=5,metrics={'error','auc'}, seed = 0)
preds = bst.predict(dtest)
labels = dtest.get_label()

bst.dump_model("model/browser_"+num_round+"_"+lambda2+"_"+alpha+"_"+eta+".txt")

