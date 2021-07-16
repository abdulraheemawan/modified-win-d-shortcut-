# -*- coding: utf-8 -*-
"""
Created on Mon Nov  9 00:49:26 2020

@author: moorish
"""

import pandas as pd
import glob
import csv
import numpy as np 
# READING ALL FILES AT ONCE AND MAKING A DF

path = '/home/moorish/Documents/SHARP-donki/SHARP-all'
all_files = glob.glob(path + "/*.csv")
li = []
for filename in all_files:
    df = pd.read_csv(filename, index_col=None, header=0)
    li.append(df)
frame = pd.concat(li, axis=0, ignore_index=True)
# frame = frame.replace(0, np.NaN)
# frame = frame.dropna(axis=0)
cols = list(frame.columns)
cols=cols[7:]
meanstd=[]
for col in cols:
    listem=[]
    listem.append(col)
    # df['{}'.format(col)] = df['{}'.format(col)].replace(0, np.NaN)
    # column=np.asarray(frame['{}'.format(col)], dtype=np.float)
    listem.append(frame['{}'.format(col)].replace([np.inf, -np.inf], np.nan).mean())  #skipna=True
    listem.append(frame['{}'.format(col)].replace([np.inf, -np.inf], np.nan).std(ddof=0))
    meanstd.append(listem)
meanstddf=pd.DataFrame(data=meanstd, columns=["Parameter", "Mean", "STD"])
meanstddf.to_csv("/home/moorish/Documents/SHARP-donki/meanstd.csv", index=False)
#%%

frame.to_csv('R:\Google Drive\.py files for algorithm\Clean run 2010\SHARP-donki\SHARP-merged.csv', index=False)

raheem=frame.drop_duplicates()

ARlist=frame.HARPNUM.tolist()
allar=list(dict.fromkeys(ARlist))
print('ARlist:',len(ARlist),'\n','allar:',len(allar))

np.savetxt("R:\Google Drive\.py files for algorithm\Clean run 2010\SHARP-donki\harpnum.csv",  
           allar, 
           delimiter =",",  
           fmt ='% s') 

# Added the line to testing branch...
# with open('GFG', 'w') as f:
#     write = csv.writer(f) 
#     write.writerows(allar)

# read=pd.read_csv(r'R:\Google Drive\.py files for algorithm\Clean run 2010\SHARP-donki\a.csv',
#                  index_col=False,names=['Name','Age','Sex'])
# raheem=read.drop_duplicates()
# a=frame.USFLUX.tolist()

# from scipy.stats import zscore
# raheem=zscore(a, axis=0)


# def z_score(df):
#     df.columns = [x + "_zscore" for x in df.columns.tolist()]
#     return ((df - df.mean())/df.std(ddof=0))
