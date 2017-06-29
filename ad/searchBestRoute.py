import sys
import re

tree_file = open('model/browser_500_0.02_0.16_0.35.txt')
index_file = open('/home/wangke/log/index_features/data')
result = open('result/xgboost_result2.txt', 'w')

deep = 2
tree_num = 400
tree_path = {}
index_map = {}
category_map = {"ad\..*": "adid", "adtp\..*": "adtp", "adbt\..*": "adbt", "adc1\..*": "adc1", "adc2\..*": "adc2","adcp\..*": "adcp","adpt\..*": "adpt", "adat\..*": "adat","adaf\..*": "adaf","tag\..*": "tag", "aictrT.*": "aictrT",
                "ua\..*": "ua", "aicvrT": "aicvrT",
                "ug\..*": "ug", "up\..*": "up", "uc\..*": "uc", "ud\..*": "ud",
		"hod&adId\..*":"hod&adId","hod&Tag\..*":"hod&Tag","ai&beh_cate_is_clk\..*":"ai&beh_cate_is_clk","beh_cate_is_clk\..*":"beh_cate_is_clk"}


def analysisFeatureNum(line):
    start = line.find('[f') + 2
    end = start
    if line.find('<') != -1:
        end = line.find('<')
    else:
        end = line.find('>')

    return line[start: end]


def checkCategory(feature):
    for reg in category_map.keys():
        if re.search(reg, feature):
            return category_map.get(reg)


try:
    for line in index_file:
        middle = line.find(',')
        feature = line[1:middle]
        index = line[middle + 1:len(line) - 2]
        index_map[index] = feature

    while tree_num > 0:
        loop = 1
        while loop <= 2:
            if loop == 2:
                root_fea = checkCategory(index_map[analysisFeatureNum(tree_file.readline())])
                leaf = 1
                while leaf <= 6:
                    if leaf == 1:
                        line = tree_file.readline()
                        if line.find("leaf") == -1:
                            leaf_fea = checkCategory(index_map[analysisFeatureNum(line)])
                            if tree_path.has_key(root_fea + "-" + leaf_fea):
                                tree_path[root_fea + "-" + leaf_fea] += 1
                            elif tree_path.has_key(leaf_fea + "-" + root_fea):
                                tree_path[leaf_fea + "-" + root_fea] += 1
                            else:
                                tree_path[root_fea + "-" + leaf_fea] = 1
                        else:
                            if tree_path.has_key(root_fea):
                                tree_path[root_fea] += 1
                            else:
                                tree_path[root_fea] = 1
                            leaf += 2
                    elif leaf == 4:
                        line = tree_file.readline()
                        if line.find("leaf") == -1:
                            leaf_fea = checkCategory(index_map[analysisFeatureNum(line)])
                            if tree_path.has_key(root_fea + "-" + leaf_fea):
                                tree_path[root_fea + "-" + leaf_fea] += 1
                            elif tree_path.has_key(leaf_fea + "-" + root_fea):
                                tree_path[leaf_fea + "-" + root_fea] += 1
                            else:
                                tree_path[root_fea + "-" + leaf_fea] = 1
                        else:
                            if tree_path.has_key(root_fea):
                                tree_path[root_fea] += 1
                            else:
                                tree_path[root_fea] = 1
                            leaf += 2
                    else:
                        tree_file.readline()
                    leaf += 1
            else:
                tree_file.readline()
            loop += 1
        tree_num -= 1

    sorted(tree_path.items(), lambda x, y: cmp(x[1], y[1]), reverse=False)

    for key in tree_path.keys():
        len = key + "," + str(tree_path.get(key)) + "\n"
        result.write(len)

finally:
    tree_file.close()
    result.close()
