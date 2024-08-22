import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import pymysql
conn=pymysql.connect(host='localhost',user='root',password='password',db='crime_data')
query="select * from crime_data"
cur=conn.cursor()
cur.execute(query)
data=cur.fetchall()

# Data frame containing crime_data
df_crime=pd.DataFrame(data,columns=["DR_NO","Date_Rptd","DATE_OCC","AREA_NAME","Crm_Cd","Crm_Cd_Desc",
                                    "Vict_Age","Vict_Sex","Premis_Desc","Status","Location","LAT","LON"])

print("Basic information on the dataset:")
df_crime.info()
print("Basic data statistics:")
print(df_crime.describe())
print("No. of unique values in each column:")
print(df_crime.nunique())
print("Unique crime codes:")
print(df_crime.Crm_Cd.unique())
print("Unique crime code description:")
print(df_crime.Crm_Cd_Desc.unique())

# Temporal analysis-Trend in crime occurrences over time
crime_grp=df_crime.groupby(by='DATE_OCC')
crime_count_ondate=crime_grp['DR_NO'].count().reset_index(name="Count of crimes")
print(crime_count_ondate)
sns.lineplot(x='DATE_OCC',y='Count of crimes',data=crime_count_ondate)
plt.xticks(rotation='vertical')
plt.title('No. of crimes vs date occurred')
plt.xlabel('Date occurred')

# Spatial analysis-Based on geographical information
plt.figure(figsize=(10, 8))
sns.scatterplot(data=df_crime, x='LAT', y='LON', marker='o', s=100, color='red')
plt.title('Crime Hotspots')
plt.xlabel('Latitude')
plt.ylabel('Longitude')
plt.grid(True)

# Location analysis
plt.figure(figsize=(10, 8))
df1=df_crime['Location'].value_counts().reset_index(name="Count")
df_new=df1[df1['Count']>2] # Only including locations where no. of crimes >2
sns.barplot(x ='Location', y='Count', data = df_new)
plt.title('Location analysis')
plt.xlabel('Location')
plt.ylabel('No. of crimes')
plt.xticks(rotation='vertical',fontsize=7)

# Distribution based on crime code
plt.figure(figsize=(10, 8))
sns.countplot(x ='Crm_Cd', data = df_crime)
plt.title('Distribution based on crime code')
plt.xlabel('Crime code')
plt.ylabel('Count')

# Victim demographics
# Distribution based on victim age
plt.figure(figsize=(10, 8))
plt.hist(x ='Vict_Age', data = df_crime)
plt.title('Distribution based on victim age')
plt.xlabel('Age')
plt.ylabel('No. of victims')

# Distribution based on victim gender
plt.figure(figsize=(10, 8))
sns.countplot(x ='Vict_Sex', data = df_crime)
plt.title('Distribution based on victim gender')
plt.xlabel('Gender')
plt.ylabel('No. of victims')

# Distribution based on premises
plt.figure(figsize=(15, 4))
sns.countplot(x ='Premis_Desc', data = df_crime)
plt.title('Distribution based on premises')
plt.xlabel('Premise')
plt.ylabel('No. of victims')
plt.xticks(rotation='vertical')

# Classification based on status
plt.figure(figsize=(10, 8))
sns.countplot(x ='Status', data = df_crime)
plt.title('Classification based on status')
plt.xlabel('Status')
plt.ylabel('No. of crimes')
plt.show()

conn.close()