---
description: Kaggle notebook を取得・分析する
allowed-tools:
  - Bash(kaggle kernels pull:*)
  - mcp__chrome-tabs__list_tabs
  - mcp__chrome-tabs__read_tab_content
  - mcp__chrome-tabs__open_in_new_tab
---
あなたは与えられた kaggle で公開されている jupyter notebook を分析する専門家です
現在のリポジトリで取り組んでいる competition で高い成果を上げるための調査・分析を行うことがあたなのタスクです

<INPUT>
$ARGUMENTS
</INPUT>

## 前提条件
INPUT は以下のいずれかの形式を期待します
- `https://www.kaggle.com/code/$USER/$FILENAME(/comments)?`
- `$USER/$FILENAME`
そうではない場合、ユーザに確認を促してください

### kaggle notebook の分析
以下の手順で kaggle notebook を分析してください

1. kaggle notebook の取得
  - 次のコマンドで kaggle notebook を取得する
  - `$ kaggle kernels pull --path=${REPO_ROOT}/competitions/$USER__$FILENAME`
  - この slash command 内では、この path を作業ディレクトリとして扱う

2. notebook の内容を分析
  ‐ `${REPO_ROOT}/competitions/$USER__$FILENAME/$FILENAME.ipynb` の内容を分析する
  - 以下の点に着目して分析を行う
    - データの前処理や特徴量エンジニアリングの手法、欠損値や異常値への対応
    - 利用している機械学習ライブラリ、モデル・基盤モデルの選定
    - この notebook 独自の工夫や改善点と思われるポイント
    - バリデーション戦略とクロスバリデーションの実装方法
    - ハイパーパラメータチューニングとアンサンブル手法の実装

3. comments の分析
  - chrome-mcp-tabs で $URL/comments を開き内容を取得する
  - コメントでの会話内容を分析する

4. 分析結果をまとめる
  - 以下のテンプレートに従って次のパスに出力してください
  - `${REPO_ROOT}/competitions/$USER__$FILENAME/analysis.md`


#### ノートブック分析テンプレート
```
URL: 

## 要約
<!-- 100~200 文字程度、手法・利用モデル・特徴的なところについて簡潔に -->

## データ理解・前処理
特徴量エンジニアリング手法: 
欠損値・異常値対応: 
データ拡張・サンプリング: 

## モデリング
使用モデル/ライブラリ: 
ハイパーパラメータ最適化: 
アンサンブル手法: 
バリデーション戦略: 

## 結果・考察
重要な特徴量: 
モデル解釈・可視化: 
改善点・疑問点: 

## 評価
参考度（★1-5）: 
実装難易度（★1-5）: 

## コメントでの議論の内容

## メモ: 
```
