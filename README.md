# Birthday Project

這是一個一次性生日驚喜製作工具，不是平台，也不是給收件人用的編輯系統。

最後真正要寄給對方的只有一個檔案：

```text
dist/birthday.html
```

或在 editor 匯出後下載的：

```text
Happy-Birthday-[名字].html
```

## 最簡單流程

1. 先封裝 editor：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build.ps1
```

2. 開啟：

```text
dist/editor.html
```

3. 填姓名、日期、題目、答案、生日信、最終告白。
4. 在「照片音樂」區加入照片與背景音樂。
5. 按「即時預覽」檢查效果。
6. 按「檢查缺漏」查看警告。
7. 按「匯出最終生日檔案」。
8. 把下載的 HTML 附加到 Gmail 寄出。

收件人不需要 `editor.html`、圖片資料夾、音樂檔、伺服器、npm、CDN 或網路。

## 素材槽

編輯器會顯示每個素材槽、預覽和清除按鈕。

建議用途：

- `memory-question`：照片猜猜看的專用照片。
- `memory-1`、`memory-2`、`memory-3`：Timeline / Gallery 回憶照片。
- `puzzle`：3x3 拼圖照片。
- `final`：最後告白照片。
- `secret`：彩蛋秘密照片。
- `music`：背景音樂。

也可以把素材放進 `assets-source/` 再 build，建議檔名：

- `memory-question.jpg`
- `memory-1.jpg`
- `memory-2.jpg`
- `memory-3.jpg`
- `puzzle.jpg`
- `final.jpg`
- `secret.jpg`
- `music.mp3`

## Gmail 寄送

1. 開 `email.html`。
2. 複製信件內容貼到 Gmail。
3. 附上最終 HTML。
4. 建議先寄給自己測試。

注意：

- Gmail 預覽不一定會執行完整互動。
- 對方應先下載附件，再用 Safari、Chrome 或 Edge 開啟。
- iPhone 可能要先存到「檔案」App，再用 Safari 開。
- 如果 Gmail 或手機阻止直接開 HTML，可以額外附 ZIP。ZIP 裡只放最終 HTML 和簡短開啟說明。

## GitHub Pages HTTPS 部署

目前已準備 GitHub Pages 部署結構：

```text
deploy/index.html
deploy/404.html
deploy/.nojekyll
deploy/robots.txt
.github/workflows/deploy-pages.yml
```

每次執行：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build.ps1
```

都會把最新 `dist/birthday.html` 複製成 `deploy/index.html`。

預設 repo 名稱建議：

```text
starlit-birthday
```

部署後網址會像：

```text
https://cl0905.github.io/starlit-birthday/
```

部署成功後，請把 `email.html` 裡的：

```text
https://cl0905.github.io/starlit-birthday/
```

替換成正式網址。這個網址目前集中在 email 裡的按鈕和純文字備援兩處。

### GitHub Pages 步驟

如果你已安裝 GitHub CLI 並登入：

```powershell
git init
git branch -M main
git add .
git commit -m "Deploy birthday page"
gh repo create starlit-birthday --public --source . --remote origin --push
```

接著到 GitHub repo 的 Settings → Pages，確認 Source 是 GitHub Actions。推送到 `main` 後 workflow 會部署 `deploy/`。

目前這台環境沒有 `gh` 指令，所以還沒有實際建立 repo 或完成 Pages 部署。

### 隱私提醒

GitHub Pages 不是密碼保護空間。`noindex` 和 `robots.txt` 只能降低搜尋引擎收錄機率，不等於真正保密。

不要放入：

- 地址、電話、身分證、學號等敏感資料。
- GitHub Token、密碼或 `.env`。
- 未壓縮原始私人照片資料夾。
- 追蹤碼或 analytics。

## 主題與功能

目前生日頁主題是黑色電影場景、玫瑰粉色粒子、高級玻璃質感和香檳金點綴。

已包含：

- 全螢幕 Canvas 粒子背景。
- 粒子圖案：禮物、愛心、名字/縮寫、旋渦、信封、蛋糕、皇冠、Happy Birthday。
- 照片猜猜看。
- Couple Quiz。
- 真 Scratch Card。
- 真 3x3 拼圖。
- Timeline 逐段揭露。
- Love Counter。
- 卡片式相簿。
- 3 個 Secret Hearts。
- 生日信。
- 生日蛋糕與吹蠟燭。
- Final 告白與約會視窗。
- 收件人進度保存與 resume。

## 檔案大小建議

- 圖片：每張原圖建議小於 8MB。
- 音樂：建議小於 5MB。
- Gmail 附件最好控制在 18MB 以下。

Editor 會估算最終 HTML 大小；`build.ps1` 會輸出 `dist/asset-stats.json`。

## 安全與離線

最終 `birthday.html` 不使用 CDN、遠端 script、iframe、analytics、tracking pixel、`eval()` 或 `new Function()`。

所有文字、照片、音樂都會寫進 HTML 檔案本身。localStorage 只保存收件人的遊玩進度，不保存寄件人的私人內容。

## 已知限制

- 瀏覽器端 editor 匯出會把圖片壓成 WebP；很老的瀏覽器如果不支援 WebP，建議用 `build.ps1` 的 JPEG 封裝流程。
- `build.ps1` 不會自動壓縮音樂，只會內嵌並提示大小。
- 麥克風是額外玩法，`file://` 或權限拒絕時直接按「吹蠟燭」即可。
- Gmail 和 iOS 可能阻止直接預覽 HTML 附件，下載後用瀏覽器開啟最穩。

