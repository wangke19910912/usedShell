import sys
import re

tree_file = open('model/xgboost_model_3.txt')
index_file = open('/home/wangke/log/index_features/data')
result = open('result/xgboost_3_result.txt', 'w')
tree_num=395
deep =3
tree_path = {}
index_map = {}
category_map = {"ad\..*": "adid", "adtp\..*": "adtp", "adbt\..*": "adbt", "adc1\..*": "adc1", "adc2\..*": "adc2",
                "adcp\..*": "adcp",
                "adpt\..*": "adpt", "adat\..*": "adat", "adaf\..*": "adaf", "tag\..*": "tag", "aictrT.*": "aictrT",
                "ua\..*": "ua", "aicvrT": "aicvrT",
                "ug\..*": "ug", "up\..*": "up", "uc\..*": "uc", "ud\..*": "ud"}


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


def readFeature(tree_file, index_map, root_fea, root_fea2):
    line = tree_file.readline()
    if line.find("leaf") == -1:
        leaf_fea = checkCategory(index_map[analysisFeatureNum(line)])
        if tree_path.has_key(root_fea + "-" + root_fea2 + "-" + leaf_fea):
            tree_path[root_fea + "-" + root_fea2 + "-" + leaf_fea] += 1

        elif tree_path.has_key(root_fea + "-" + leaf_fea + "-" + root_fea2):
            tree_path[root_fea + "-" + leaf_fea + "-" + root_fea2] += 1

        elif tree_path.has_key(leaf_fea + "-" + root_fea + "-" + root_fea2):
            tree_path[leaf_fea + "-" + root_fea + "-" + root_fea2] += 1

        elif tree_path.has_key(leaf_fea + "-" + root_fea2 + "-" + root_fea):
            tree_path[leaf_fea + "-" + root_fea2 + "-" + root_fea] += 1

        elif tree_path.has_key(root_fea2 + "-" + leaf_fea + "-" + root_fea):
            tree_path[root_fea2 + "-" + leaf_fea + "-" + root_fea] += 1

        elif tree_path.has_key(root_fea2 + "-" + root_fea + "-" + leaf_fea):
            tree_path[root_fea2 + "-" + root_fea + "-" + leaf_fea] += 1
        else:
            tree_path[root_fea + "-" + root_fea2 + "-" + leaf_fea] = 1
        return True
    else:
        if tree_path.has_key(root_fea2 + "-" + root_fea):
            tree_path[root_fea2 + "-" + root_fea] += 1
        elif tree_path.has_key(root_fea + "-" + root_fea2):
            tree_path[root_fea + "-" + root_fea2] += 1
        else:
            tree_path[root_fea2 + "-" + root_fea] = 1
        return False


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
		line4=tree_file.readline()
		print line4
                root_fea = checkCategory(index_map[analysisFeatureNum(line4)])
                loop2 = 1
                while loop2 <= 2:
                    '''if loop2 == 2:'''
                    leaf = 1
                    line2 = tree_file.readline();
                    root_fea2 = checkCategory(index_map[analysisFeatureNum(line2)])
                    while leaf <= 6:
                        if leaf == 1:
                            if readFeature(tree_file, index_map, root_fea, root_fea2) == False:
                                leaf += 2
                        elif leaf == 4:
                            if readFeature(tree_file, index_map, root_fea, root_fea2) == False:
                                leaf += 2
                        else:
                            tree_file.readline()
                        leaf += 1
                    '''else:
                        tree_file.readline()'''
                    loop2 += 1
            else:
                tree_file.readline()
            loop += 1
        tree_num -= 1

    for key in tree_path.keys():
        len = key + "," + str(tree_path.get(key)) + "\n"
        result.write(len)

finally:
    tree_file.close()
    result.close()
