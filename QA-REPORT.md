# QA Report

測試日期：2026-09-18  
測試環境：Windows、PowerShell、Node.js syntax check、OpenClaw browser doctor、靜態掃描、`file://` 單檔複製檢查

## 結論

目前專案已輸出寄出前編輯器、Gmail 邀請信、單檔生日頁、PowerShell build 流程與最終 ZIP。

`dist/birthday.html` 是唯一要寄給收件人的最終互動檔案。它不依賴 `editor.html`、圖片資料夾、音樂檔、localhost、API、CDN 或外部網站。

## 檔案大小

- `dist/birthday.html`：46,425 bytes，約 45.3 KB
- `dist/editor.html`：88,136 bytes，約 86.1 KB
- `dist/birthday-package.zip`：約 92.4 KB
- `dist/asset-stats.json`：185 bytes

目前 `assets-source/` 尚未放正式照片與音樂，所以圖片與音樂占用大小為 0。正式匯出後請看 editor 內的大小估算，或 `dist/asset-stats.json`。

## 已測試通過

- `birthday.html` JavaScript 語法檢查通過。
- `editor.html` JavaScript 語法檢查通過。
- `email.html` 無前台互動 script，為 table-based email HTML。
- `dist/birthday.html` JavaScript 語法檢查通過。
- `dist/editor.html` JavaScript 語法檢查通過。
- `dist/birthday.html` 可被單獨複製到系統暫存資料夾，檔案非空且不需要旁邊素材。
- `dist/editor.html` 內嵌的 birthday template 可被匯出 regex 正確命中。
- 靜態掃描未發現遠端 script、iframe、CDN、analytics、tracking、localhost、`eval()` 或 `new Function()`。
- 掃描中唯一的 SVG namespace 是 data URI 內部文字，不是外部請求。
- `tools/build.ps1` 可產生 `dist/birthday.html`、`dist/editor.html`、`dist/asset-stats.json` 與 `dist/birthday-package.zip`。
- OpenClaw browser doctor 通過，Chrome / CDP 可用。

## 已修復項目

- 最終生日頁不再依賴寄件人 localStorage 載入私人內容。
- Editor 匯出會把 CONFIG 真正寫入生日 HTML。
- Editor 內嵌模板 placeholder 替換修正，不會再誤判尚未 build。
- `memory-question` 已成為照片猜猜看的專用照片槽，不再偷用 Timeline 的 `memory-1`。
- Editor 新增照片預覽、清除、上傳狀態與音樂預覽。
- Editor 匯出前會列出必要照片、音樂、示範姓名、示範信件、示範告白等 placeholder 警告。
- 粒子亮度、密度、拖尾與聚合圖案已強化。
- Final 結束後加入約會彈窗；按「不願意」會讓「願意」逐步變大，按「願意」會顯示「請與CL聯絡安排約會^^」。
- README 已更新成白話寄送流程。
- `assets-source/README.md` 已補上 `memory-question.jpg`。

## 功能覆蓋

- Story State Machine：INTRO → MEMORY → QUIZ → SCRATCH → PUZZLE → TIMELINE → COUNTER → GALLERY → SECRET RESULT → LETTER → CAKE → FINAL。
- 粒子圖案：禮物、愛心、文字/名字、旋渦、信封、蛋糕、皇冠、Happy Birthday。
- 照片猜題：模糊照片、三選項、答錯震動、答對顯影。
- Couple Quiz：3 題預設、分數結果、答錯提示。
- Scratch Card：Canvas 遮罩、Pointer Events、DPR、60% 刮除判定、Canvas fallback。
- Puzzle：3x3 背景切格、點兩塊交換、真排列完成判定。
- Timeline：逐段揭露事件。
- Love Counter：由紀念日即時計算天、時、分、秒。
- Gallery：堆疊卡片、左右滑動、點擊翻面、鍵盤方向鍵。
- Secret Hearts：三章節彩蛋、`♡ 1/3` 計數、秘密結果頁。
- Letter：安靜模式、信封、逐段 fade reveal，文字使用 DOM API 插入。
- Cake：先許願、按鈕吹蠟燭、麥克風 fallback、煙霧、暗場、confetti。
- Final：黑場後逐行揭露、最終照片、生日文字、告白、署名、再看一次確認。
- 收件人 localStorage 僅保存遊玩進度。

## 未能自動完成的測試

OpenClaw browser 工具本身阻擋 `file://` 與 `127.0.0.1` navigation，因此這次無法用該工具自動跑完整瀏覽器點擊路徑。專案本機也沒有 Playwright test runner dependency。

因此以下項目仍需要真人在手機與桌面瀏覽器實測：

- iPhone Safari 下載附件後開啟。
- Gmail app 附件下載後開啟。
- Scratch 實際手指刮除手感。
- 麥克風權限拒絕與允許兩條路。
- 長照片、正式音樂與大量 Data URI 後的效能。
- 375×667、390×844、430×932、tablet、desktop、landscape 的完整手動路徑。

## 已知限制

- 目前沒有正式照片與音樂，因此圖片載入、音樂播放與附件大小只以 placeholder / 空素材狀態驗證。
- Editor 端圖片壓縮使用瀏覽器能力，會優先輸出 WebP；很舊瀏覽器可能不支援。
- `build.ps1` 可封裝本機素材並轉 JPEG，但不會自動壓縮音樂。
- 麥克風在 `file://`、iOS 或權限拒絕時可能不可用，但可以用「吹蠟燭」按鈕完成流程。
- Gmail 與 iOS 可能阻止直接預覽 HTML 附件，建議下載後用 Safari、Chrome 或 Edge 開啟。

## Gmail 與安全限制

- Gmail 信件本體不會執行附件中的互動。
- Gmail app 可能只顯示預覽或阻止 JavaScript。
- iPhone 可能需要先下載到「檔案」App，再用 Safari 開。
- HTML 附件如被封鎖，可額外附 ZIP；ZIP 內仍只放清楚命名的最終 HTML。
- 麥克風只做本機音量分析，不錄音、不保存、不上傳。
