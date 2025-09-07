# Ubuntu/Debian用cake-autortt

## 🌐 Language / 语言 / Bahasa / Язык / 言語 / Ngôn ngữ / Dil / اللغة

[English](README.md) | [中文](README_zh.md) | [Bahasa Indonesia](README_id.md) | [Русский](README_ru.md) | **日本語** | [Tiếng Việt](README_vi.md) | [Türkçe](README_tr.md) | [العربية](README_ar.md)

---

**測定されたネットワーク状況に基づいてCAKE qdiscのRTTパラメータを自動調整**

これは、systemd、aptパッケージ管理、OpenWrtのUCIシステムではなく従来の設定ファイルを使用する標準的なLinuxディストリビューション向けに適応されたcake-autorttの**Ubuntu/Debianポート**です。

## 🌍 なぜこれがあなたのインターネット体験にとって重要なのか

ほとんどのユーザーは、YouTube、Netflix、Googleなどの主要なウェブサイトの高速読み込みに慣れています。これらのサイトは、ユーザーの非常に近くにサーバーを配置するコンテンツ配信ネットワーク（CDN）を使用しており、通常50-100ms未満の応答時間を提供しています。しかし、インターネットはこれらの大手プラットフォームよりもはるかに広大です。

**主要なCDN対応サイト以外のサイトを閲覧する際、多様なサーバーの世界に遭遇します：**
- **ローカル/地域サービス**：中小企業、地元ニュースサイト、コミュニティフォーラム、地域サービスは、しばしばあなたの国や地域にサーバーを持っています（10-50ms RTT）
- **国際コンテンツ**：専門ウェブサイト、学術リソース、ゲームサーバー、ニッチサービスは他の大陸でホストされている可能性があります（100-500ms RTT）
- **リモートインフラストラクチャ**：一部のサービス、特に発展途上地域や専門アプリケーションでは、大幅に高い遅延を持つ場合があります

**CAKEのRTTパラメータは、キュー管理アルゴリズムが輻輳にどれだけ積極的に反応するかを制御します。** デフォルトでは、CAKEは100msのRTT仮定を使用し、これは一般的なインターネットトラフィックに対してかなりうまく機能します。しかし：

- **RTT設定が低すぎる場合**：CAKEがネットワークのRTTが実際よりも短いと考える場合、キューが蓄積されたときにパケットドロップに対して過度に積極的になり、リモートサーバーの帯域幅を潜在的に減少させます
- **RTT設定が高すぎる場合**：CAKEがネットワークのRTTが実際よりも長いと考える場合、過度に保守的になり、大きなキューの蓄積を許可し、近くのサーバーに不要な遅延を作成します

**実世界の影響例：**
- **シンガポールのユーザー → ドイツのサーバー**：RTT調整なしでは、ドイツのウェブサイト（≈180ms RTT）にアクセスするシンガポールのユーザーは、CAKEのデフォルト100ms設定が早期パケットドロップを引き起こすため、帯域幅の減少を経験する可能性があります
- **米国の農村部 → 地域サーバー**：地域サーバー（≈25ms RTT）にアクセスする米国農村部のユーザーは、CAKEのデフォルト100ms設定が必要以上にキューの成長を許可するため、必要以上に高い遅延を経験する可能性があります
- **ゲーミング/リアルタイムアプリケーション**：遅延と帯域幅の両方に敏感なアプリケーションは、実際のネットワーク状況に一致するRTT調整から大幅に恩恵を受けます

**cake-autorttの支援方法：**
通信している実際のサーバーへの実際のRTTを自動測定し、それに応じてCAKEパラメータを調整することで、以下を得られます：
- 近くのサーバーアクセス時の**より高速な応答性**（短いRTT → より積極的なキュー管理）
- リモートサーバーアクセス時の**より良い帯域幅**（長いRTT → より忍耐強いキュー管理）
- 仮定ではなく実際のネットワーク状況に適応する**最適なbufferbloat制御**

これは、多様なコンテンツソースに定期的にアクセスし、国際サービスと連携し、またはインターネットトラフィックが頻繁に長距離を移動する地域に住むユーザーにとって特に価値があります。

## 🚀 機能

- **自動RTT発見**：`/proc/net/nf_conntrack`を通じてアクティブな接続を監視し、外部ホストへのRTTを測定
- **スマートホストフィルタリング**：LANアドレスを自動的にフィルタリングし、外部ホストに焦点を当てる
- **スマートRTTアルゴリズム**：組み込みpingコマンドを使用して各ホストに個別にRTTを測定（ホストあたり3回のping）、その後最適なパフォーマンスのために平均と最悪のRTTを知的に選択
- **自動インターフェース発見**：CAKE対応インターフェースを自動的に発見
- **systemd統合**：自動起動とプロセス管理を備えた適切なsystemdサービスとして動作
- **設定可能なパラメータ**：すべてのタイミングと動作パラメータは設定ファイルを通じて設定可能
- **堅牢なエラー処理**：欠落した依存関係、ネットワーク問題、インターフェース変更を優雅に処理
- **最小限の依存関係**：pingとtcのみが必要 - 追加パッケージは不要、すべてのシステムで利用可能な組み込みユーティリティを使用
- **高精度RTT**：正確なネットワークタイミング調整のために小数RTT値（例：100.23ms）をサポート

## 🔧 互換性

**テスト済みで動作：**
- **Ubuntu 20.04+（Focal以降）**
- **Debian 10+（Buster以降）**

**期待される互換性：**
- CAKE qdiscサポートを持つsystemdベースのLinuxディストリビューション
- 現代的なiproute2パッケージを持つディストリビューション

**互換性要件：**
- CAKEqdiscカーネルモジュール（Linux 4.19+で利用可能）
- pingユーティリティ（すべての標準Linuxディストリビューションに含まれる）
- systemdサービス管理
- tcユーティリティを持つiproute2（トラフィック制御）
- /proc/net/nf_conntrackサポート（netfilter conntrack）

## 📋 要件

### 依存関係
- **ping**：RTT測定用の標準pingユーティリティ（すべてのLinuxディストリビューションに含まれる）
- **tc**：トラフィック制御ユーティリティ（iproute2の一部）
- **CAKE qdisc**：ターゲットインターフェースで設定されている必要があります
- **systemd**：サービス管理
- **netfilter conntrack**：接続追跡用（/proc/net/nf_conntrack）

### 依存関係のインストール

```bash
# 必要なパッケージをインストール
sudo apt update
sudo apt install iputils-ping iproute2

# tcがCAKEをサポートしているかチェック：
tc qdisc help | grep cake

# conntrackの可用性をチェック
ls /proc/net/nf_conntrack
```

## 🔧 インストール

> [!IMPORTANT]  
> インストールスクリプトを実行する前に、ネットワークインターフェースでCAKE qdiscを設定し、システムの正しいインターフェース名を設定するために設定ファイルを編集する必要があります。

### 前提条件：CAKE qdisc設定

まず、ネットワークインターフェースでCAKE qdiscを設定する必要があります。これは通常、インターネット向けインターフェースで行われます：

```bash
# 例：メインインターフェースでCAKEを設定
# 'eth0'を実際のインターフェース名に置き換える
# '100Mbit'を実際の帯域幅に置き換える

# シンプルな設定の場合（eth0をあなたのインターフェースに置き換える）：
sudo tc qdisc add root dev eth0 cake bandwidth 100Mbit

# 入力シェーピングを含むより高度な設定の場合：
# ダウンロードシェーピング用のifb（intermediate functional block）インターフェースを作成
sudo modprobe ifb
sudo ip link add name ifb0 type ifb
sudo ip link set dev ifb0 up

# 入力トラフィックリダイレクトとCAKEを設定
sudo tc qdisc add dev eth0 handle ffff: ingress
sudo tc filter add dev eth0 parent ffff: protocol all u32 match u32 0 0 action mirred egress redirect dev ifb0
sudo tc qdisc add root dev ifb0 cake bandwidth 500Mbit ingress

# アップロードCAKEを設定
sudo tc qdisc add root dev eth0 cake bandwidth 50Mbit

# CAKEが設定されていることを確認
tc qdisc show | grep cake
```

### クイックインストール

1. **CAKEインターフェースを設定（上記セクション参照）**

2. **設定ファイルを編集：**

```bash
# インターフェース名に合わせて設定ファイルを編集
nano etc/default/cake-autortt
```

3. **インターフェース名を設定：**

ネットワーク設定に合わせて`DL_INTERFACE`（ダウンロード）と`UL_INTERFACE`（アップロード）設定を更新：

```bash
# 異なる設定の設定例：

# シンプルな設定の場合（両方向に1つのインターフェース）：
DL_INTERFACE="eth0"
UL_INTERFACE="eth0"

# 入力シェーピング用ifbインターフェースを使用した高度な設定の場合：
DL_INTERFACE="ifb0"     # ダウンロードインターフェース（入力トラフィックシェーピング用ifb）
UL_INTERFACE="eth0"     # アップロードインターフェース（物理インターフェース）

# カスタムインターフェース名の場合：
DL_INTERFACE="enp3s0"   # 特定のダウンロードインターフェース
UL_INTERFACE="enp3s0"   # 特定のアップロードインターフェース
```

**インターフェース名を見つける方法：**
```bash
# CAKE qdiscを持つインターフェースをリスト
tc qdisc show | grep cake

# すべてのネットワークインターフェースをリスト
ip link show

# メインネットワークインターフェースをチェック
ip route | grep default
```

4. **インストールスクリプトを実行：**

```bash
# インストールスクリプトを実行可能にして実行
chmod +x install.sh
sudo ./install.sh
```

### 手動インストール

1. **サービスファイルをシステムにコピー：**

```bash
# メイン実行ファイルをコピー
sudo cp usr/bin/cake-autortt /usr/bin/
sudo chmod +x /usr/bin/cake-autortt

# systemdサービスファイルをコピー
sudo cp etc/systemd/system/cake-autortt.service /etc/systemd/system/

# 設定ファイルをコピー
sudo cp etc/default/cake-autortt /etc/default/

# インターフェース監視用udevルールをコピー
sudo cp etc/udev/rules.d/99-cake-autortt.rules /etc/udev/rules.d/

# systemdとudevをリロード
sudo systemctl daemon-reload
sudo udevadm control --reload-rules
```

2. **サービスを有効化して開始：**

```bash
# ブート時の自動起動のためにサービスを有効化
sudo systemctl enable cake-autortt

# サービスを開始
sudo systemctl start cake-autortt
```

## 🗑️ アンインストール

システムからcake-autorttを削除するには：

```bash
# アンインストールスクリプトを実行可能にして実行
chmod +x uninstall.sh
sudo ./uninstall.sh
```

アンインストールスクリプトは：
- サービスを停止して無効化
- インストールされたすべてのファイルを削除
- オプションで設定ファイルとバックアップを削除
- 一時ファイルをクリーンアップ

## ⚙️ 設定

### 🔧 インターフェース設定（必須）

**最も重要な設定ステップは正しいインターフェース名の設定です。** 正しいインターフェース名なしではサービスは適切に動作しません。

```bash
# 現在の設定を表示
cat /etc/default/cake-autortt

# 設定を編集
sudo nano /etc/default/cake-autortt

# 変更を適用するためにサービスを再起動
sudo systemctl restart cake-autortt
```

サービスは`/etc/default/cake-autortt`を通じて設定されます。このファイルを編集することですべてのパラメータを設定できます。

### 設定パラメータ

| パラメータ | デフォルト | 説明 |
|-----------|---------|-------------|
| `DL_INTERFACE` | auto | ダウンロードインターフェース名（例：'eth0'、'ifb0'） |
| `UL_INTERFACE` | auto | アップロードインターフェース名（例：'eth0'、'enp3s0'） |
| `RTT_UPDATE_INTERVAL` | 5 | qdisc RTTパラメータ更新間隔（秒） |
| `MIN_HOSTS` | 3 | RTT計算に必要な最小ホスト数 |
| `MAX_HOSTS` | 100 | 順次プローブする最大ホスト数 |
| `RTT_MARGIN_PERCENT` | 10 | 測定RTTに追加される安全マージン（パーセント） |
| `DEFAULT_RTT_MS` | 100 | 利用可能なホストが不十分な場合のデフォルトRTT |
| `DEBUG` | 0 | デバッグログを有効化（0=無効、1=有効） |

> [!NOTE]  
> インターフェースパラメータはデフォルトで"auto"ですが、自動検出はすべての設定で確実に動作しない場合があります。これらの値を明示的に設定することを強く推奨します。

> [!TIP]  
> 高活動ネットワーク（例：大学キャンパス、多くのアクティブユーザーを持つパブリックネットワーク）の場合、ネットワーク特性に基づいて`RTT_UPDATE_INTERVAL`の調整を検討してください。デフォルトの5秒はほとんどのシナリオでうまく機能しますが、より安定したネットワークでは10-15秒に増やすか、非常に動的な環境では3秒に減らすことができます。

### 設定例

```bash
# /etc/default/cake-autortt

# ネットワークインターフェース（必須 - インストールに合わせて設定）
DL_INTERFACE="ifb0"      # ダウンロードインターフェース
UL_INTERFACE="eth0"      # アップロードインターフェース

# タイミングパラメータ
RTT_UPDATE_INTERVAL=5    # 5秒ごとにRTTを更新
MIN_HOSTS=3              # 測定に最低3ホスト必要
MAX_HOSTS=100            # 最大100ホストをサンプル
RTT_MARGIN_PERCENT=10    # 10%の安全マージンを追加
DEFAULT_RTT_MS=100       # フォールバックRTT値

# デバッグ
DEBUG=0                  # 詳細ログには1に設定
```

## 🔍 動作原理

1. **接続監視**：定期的に`/proc/net/nf_conntrack`を解析してアクティブなネットワーク接続を特定
2. **ホストフィルタリング**：宛先IPアドレスを抽出し、プライベート/LANアドレスをフィルタリング
3. **RTT測定**：`ping`を使用して各外部ホストに個別にRTTを測定（ホストあたり3回のping）
4. **スマートRTT選択**：ネットワーク輻輳を防ぐためにホストを順次pingし、平均と最悪のRTTを計算し、すべての接続の最適なパフォーマンスを確保するためにより高い値を使用
5. **安全マージン**：適切なバッファリングを確保するために測定RTTに設定可能なマージンを追加
6. **qdisc更新**：ダウンロードとアップロードインターフェースでCAKE qdisc RTTパラメータを更新

### 🧠 スマートRTTアルゴリズム

バージョン1.2.0以降、cake-autorttはDave Täht（CAKEの共同作成者）の推奨に基づく知的RTT選択アルゴリズムを実装しています：

**問題**：一部のホストが他のホストよりも大幅に高い遅延を持つ場合、平均RTTのみを使用することは問題となる可能性があります。例えば、平均RTT 40msの100ホストがあるが、2ホストが234msと240msのRTTを持つ場合、平均40msを使用すると、これらの高遅延接続でパフォーマンス問題が発生する可能性があります。

**解決策**：アルゴリズムは現在：
1. **すべての応答ホストから平均と最悪の両方のRTTを計算**
2. **2つの値を比較**し、適切なものを知的に選択
3. **最悪のRTTが平均より大幅に高い場合は最悪のRTTを使用**してすべての接続の良好なパフォーマンスを確保
4. **最悪のRTTが平均に近い場合は平均RTTを使用**して過度に保守的な設定を避ける

**なぜこれが重要か**：[Dave Täht](https://forum.mikrotik.com/t/fq-codel-cake-stories/181067/17)によると、「特に入力シェーピングでは、ISPシェーパーに到達する前にキュー制御を取得するために、典型的なRTTを推定として使用する方が良い」。しかし、任意のホストへの実際のRTTがCAKEインターフェースで設定されたRTTより長い場合、パフォーマンスが大幅に低下する可能性があります。

**実世界の例**：
- 98ホストが30-50ms RTT（平均：42ms）
- 2ホストが200ms+ RTT（最悪：234ms）
- **旧アルゴリズム**：平均45msを使用し、200ms+ホストで問題を引き起こす
- **新アルゴリズム**：最悪RTT 234msを使用し、すべての接続で最適なパフォーマンスを確保

### 接続フローの例

```
[ホスト/アプリケーション] → [インターフェースのCAKE] → [インターネット]
                            ↑
                      cake-autorttが監視
                      アクティブ接続と
                      RTTパラメータを調整
```

## 📊 期待される動作

インストールと起動後、以下を観察するはずです：

### 即座の効果
- サービスはsystemdを通じて自動的に開始し、接続の監視を開始
- RTT測定がシステムログに記録される（デバッグが有効な場合）
- 測定されたネットワーク状況に基づいて30秒ごとにCAKE qdisc RTTパラメータが更新
- 高精度RTT値（例：44.89ms）がCAKE qdiscに適用

### 長期的な利点
- **改善された応答性**：RTTパラメータが実際のネットワーク状況と最新の状態を保つ
- **より良いBufferbloat制御**：CAKEがキュー管理についてより情報に基づいた決定を行える
- **適応的パフォーマンス**：変化するネットワーク状況（衛星、セルラー、輻輳リンク）に自動的に適応
- **より高い精度**：より良いネットワーク状況表現のために最大20ホストをサンプリング

### 監視

```bash
# サービスステータスをチェック
sudo systemctl status cake-autortt

# サービスログを表示
sudo journalctl -u cake-autortt -f

# CAKE qdiscパラメータを監視
tc qdisc show | grep cake

# 詳細ログのためのデバッグモード
sudo nano /etc/default/cake-autortt
# DEBUG=1に設定、その後：
sudo systemctl restart cake-autortt
```

## 🔧 トラブルシューティング

### 一般的な問題

1. **サービスが開始しない**
   ```bash
   # 依存関係をチェック
   which ping tc
   
   # CAKEインターフェースをチェック
   tc qdisc show | grep cake
   
   # サービスログをチェック
   sudo journalctl -u cake-autortt --no-pager
   ```

2. **RTT更新なし**
   ```bash
   # デバッグモードを有効化
   sudo nano /etc/default/cake-autortt
   # DEBUG=1に設定
   
   sudo systemctl restart cake-autortt
   
   # ログをチェック
   sudo journalctl -u cake-autortt -f
   ```

3. **インターフェース検出失敗**
   ```bash
   # 設定でインターフェースを手動指定
   sudo nano /etc/default/cake-autortt
   # DL_INTERFACEとUL_INTERFACEを設定
   
   sudo systemctl restart cake-autortt
   ```

4. **CAKE qdiscが見つからない**
   ```bash
   # CAKEサポートをチェック
   tc qdisc help | grep cake
   
   # インターフェースでCAKEが設定されているかチェック
   tc qdisc show
   
   # 必要に応じてCAKEを設定（インストールセクション参照）
   ```

### デバッグ情報

デバッグが有効（`/etc/default/cake-autortt`で`DEBUG=1`）の場合、サービスは詳細なログを提供します：

**デバッグ出力例：**
```bash
Jan 09 18:34:22 hostname cake-autortt[1234]: DEBUG: Extracting hosts from conntrack
Jan 09 18:34:22 hostname cake-autortt[1234]: DEBUG: Found 35 non-LAN hosts
Jan 09 18:34:22 hostname cake-autortt[1234]: DEBUG: Measuring RTT using ping for 35 hosts (3 pings each)
Jan 09 18:34:25 hostname cake-autortt[1234]: DEBUG: ping summary: 28/35 hosts alive
Jan 09 18:34:25 hostname cake-autortt[1234]: DEBUG: Using average RTT: 45.2ms (avg: 45.2ms, worst: 89.1ms)
Jan 09 18:34:25 hostname cake-autortt[1234]: DEBUG: Using measured RTT: 45.2ms
Jan 09 18:34:35 hostname cake-autortt[1234]: INFO: Adjusting CAKE RTT to 49.72ms (49720us)
Jan 09 18:34:35 hostname cake-autortt[1234]: DEBUG: Updated RTT on download interface ifb0
Jan 09 18:34:35 hostname cake-autortt[1234]: DEBUG: Updated RTT on upload interface eth0
```

> [!NOTE]  
> **メモリ効率的なログ**：デバッグログはログの氾濫を防ぐために最適化されています。個別のホストRTT測定はメモリ使用量とディスク書き込みを減らすためにログに記録されません。systemdジャーナルには要約情報のみがログされ、過度なログ増加なしに継続的な操作に適しています。

## 🔄 OpenWrtバージョンとの違い

このUbuntu/Debianポートは、いくつかの重要な側面でOpenWrtバージョンと異なります：

### 設定システム
- **OpenWrt**：UCI設定システムを使用（`uci set`、`/etc/config/cake-autortt`）
- **Ubuntu/Debian**：従来の設定ファイルを使用（`/etc/default/cake-autortt`）

### サービス管理
- **OpenWrt**：procdとOpenWrt init.dスクリプトを使用
- **Ubuntu/Debian**：systemdサービス管理を使用

### インターフェース監視
- **OpenWrt**：インターフェースイベント用hotplug.dスクリプトを使用
- **Ubuntu/Debian**：インターフェース監視用udevルールを使用

### パッケージ管理
- **OpenWrt**：opkgパッケージマネージャーを使用
- **Ubuntu/Debian**：aptパッケージマネージャーを使用

### ファイル場所
- **OpenWrt**：OpenWrt固有のパスを使用（`/etc/config/`、`/etc/hotplug.d/`）
- **Ubuntu/Debian**：標準Linuxパスを使用（`/etc/default/`、`/etc/systemd/`、`/etc/udev/`）

## 📄 ライセンス

このプロジェクトはGNU General Public License v2.0の下でライセンスされています - 詳細は[LICENSE](../LICENSE)ファイルを参照してください。

## 🤝 貢献

貢献を歓迎します！プルリクエストの提出をお気軽にどうぞ。Ubuntu/Debianポートに貢献する際は、Ubuntu LTSバージョンと現在の安定版Debianの両方との互換性を確保してください。