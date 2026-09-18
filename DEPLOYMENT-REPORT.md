# Deployment Report

日期：2026-09-18  
狀態：本機 GitHub Pages 部署檔已完成；正式 GitHub repo / Pages 尚未建立。

## 1. GitHub Repository 網址

尚未建立。

原因：目前環境沒有 `gh` GitHub CLI 指令，無法確認登入狀態、建立 repository、push 或啟用 Pages。

## 2. GitHub Pages 正式網址

尚未建立。

預期格式：

```text
https://cl0905.github.io/starlit-birthday/
```

## 3. Repository Visibility

尚未建立。建議使用 Public repository，因為 GitHub Pages 免費公開網站最簡單。

## 4. 部署時間

尚未完成線上部署。本機部署包最後 build 時間請查看 `dist/asset-stats.json`。

## 5. 部署 Branch

Workflow 預設從 `main` branch 部署。

## 6. GitHub Actions 狀態

尚未執行。已建立：

```text
.github/workflows/deploy-pages.yml
```

Workflow 使用 GitHub 官方 Pages Actions：

- `actions/checkout@v4`
- `actions/configure-pages@v5`
- `actions/upload-pages-artifact@v3`
- `actions/deploy-pages@v4`

權限：

- `contents: read`
- `pages: write`
- `id-token: write`

## 7. 正式網站是否能開啟

尚未有正式網址，因此尚未完成線上開啟測試。

## 8. `index.html` 大小

`deploy/index.html` 由 `dist/birthday.html` 複製而來。最新本機 build 大小為 46,425 bytes，約 45.3 KB。

## 9. 首次載入總大小

目前 deploy 版本所有內容都內嵌於 `index.html`，首次載入總大小約等於 `deploy/index.html`。

正式照片與音樂加入後，大小會隨 Data URI 增加。

## 10. 圖片與音樂總大小

目前沒有正式素材，`dist/asset-stats.json` 顯示圖片與音樂為空。

正式素材加入後請看：

```text
dist/asset-stats.json
```

## 11. 外部請求

靜態掃描未發現遠端 script、iframe、CDN、analytics、tracking、localhost、`eval()` 或 `new Function()`。

## 12. iPhone 真機測試

尚未完成真機測試。

原因：目前沒有可用的 GitHub Pages 正式網址，也沒有真實 iPhone 測試裝置由工具控制。

## 13. 已測試通過

- `birthday.html` / `editor.html` / `dist/birthday.html` / `dist/editor.html` JS syntax check。
- 單檔複製檢查。
- `dist/editor.html` 內嵌 birthday template 檢查。
- 外部請求風險靜態掃描。
- `tools/build.ps1` 可產生 `deploy/index.html`、`deploy/404.html`、`deploy/.nojekyll`、`deploy/robots.txt`。

## 14. 仍有限制

- GitHub CLI 不存在，尚未建立 repo、push 或部署。
- 尚未完成 HTTPS 正式網址測試。
- 尚未完成 iPhone / Android 真機測試。
- 正式照片與音樂尚未加入，因此正式載入大小與行動網路效能還需在放素材後再測。

## 15. Gmail 按鈕

`email.html` 已改成 HTTPS 按鈕流程。

目前 placeholder URL：

```text
https://cl0905.github.io/starlit-birthday/
```

正式部署後需要替換成真正 Pages URL。

## 16. 以後如何重新部署

1. 用 `dist/editor.html` 匯出最新生日 HTML，或更新素材後執行 build。
2. 執行：

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\build.ps1
```

3. 確認 `deploy/index.html` 已更新。
4. commit 並 push 到 `main`。
5. GitHub Actions 會自動部署。

## 17. 網址失效時如何檢查

1. 到 GitHub repo 的 Actions 看 `Deploy birthday page` 是否失敗。
2. 到 Settings → Pages 確認 Source 是 GitHub Actions。
3. 確認 `deploy/index.html` 存在。
4. 確認 repo 是 Public，或你的 Pages 設定支援目前 visibility。
5. 等待 GitHub Pages CDN 更新，通常需要數十秒到數分鐘。

## 18. 私人原始檔公開檢查

已建立 `.gitignore`：

- 忽略 `.env`、token/secret/key 類檔案。
- 忽略 `assets-source/*`，只保留 `assets-source/README.md`。
- 忽略 `dist/*.zip`。

`deploy/` 只應包含收件人需要看的生日頁、`.nojekyll`、`robots.txt` 和 optional `404.html`。

## 需要你提供或安裝

要完成真正 GitHub Pages 部署，還需要其中一種方式：

1. 安裝並登入 GitHub CLI：`gh auth login`。
2. 告訴我 GitHub 帳號名稱、Repository 名稱，以及是否建立 Public repo，然後你在本機完成 GitHub 授權流程。

不要提供 GitHub 密碼或 token 到對話中。

