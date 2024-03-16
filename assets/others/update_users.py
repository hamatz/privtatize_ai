# アクセストークン等の情報をプロビジョニングしたい場合のバックエンド側処理のサンプル
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import csv

# Firebaseプロジェクトの設定ファイルを使用して初期化
cred = credentials.Certificate('path/to/your/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

# CSVファイル1の読み込みと整形
departments = {}
with open('departments.csv', mode='r', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        department_name = row['部署名']
        departments[department_name] = {
            'accessToken': row['アクセストークン'],
            'hostName': row['Host名'],
            'apiVersion': row['APIバージョン'],
            'gptModelName': row['GPTモデル名']
        }
# CSVファイル2の読み込みと整形
users = []
with open('users.csv', mode='r', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        user_info = {
            'department': row['部署名'],
            'location': departments[row['部署名']],
            'userName': row['ユーザー名'],
            'email': row['メールアドレス']
        }
        users.append(user_info)

# 部署情報のアップロード
for department_name, info in departments.items():
    db.collection('departments').document(department_name).set(info)

# ユーザ情報のアップロード
for user in users:
    db.collection('users').add(user)
