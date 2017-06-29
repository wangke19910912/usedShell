import sys
import numpy as np
#import AUC as auc
import xgboost as xgb

dtrain = xgb.DMatrix('/home/wangke/log/features_with_index/small/train')
#dtest = xgb.DMatrix('./feature_svm_file/Test.data')
dtest = xgb.DMatrix('/home/wangke/log/features_with_index/small/test')
#param = {'max_depth':2,'lambda':0.01,'alpha':0.14, 'eta':0.35, 'silent':1, 'objective':'binary:logistic'}

#param = {'max_depth':2,'lambda':0.0.1,'alpha':0.14, 'eta':0.30, 'silent':1, 'objective':'binary:logistic','eval_metric':['error','auc']}

num_round=sys.argv[1]#300
lambda2=sys.argv[2]#0.02
alpha=sys.argv[3]#0.14
eta=sys.argv[4]#0.3

param = {'max_depth':3,'lambda':lambda2,'alpha':alpha, 'eta':eta, 'silent':1, 'objective':'binary:logistic','eval_metric':['error','auc']}

watchlist  = [(dtest,'test'), (dtrain,'train')]
bst = xgb.train(param, dtrain, int(num_round), watchlist)
preds = bst.predict(dtest)
labels = dtest.get_label()

file_name="model/small_"+num_round+"_"+lambda2+"_"+alpha+".txt"

bst.dump_model(file_name);
#auc_value = auc.scoreAUC(labels,preds)
#print auc_value

