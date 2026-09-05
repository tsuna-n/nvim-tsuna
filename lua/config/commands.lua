local M = {}

local help_lines = {
  "คู่มือคีย์ลัด Neovim แบบ IDE",
  "========================================",
  "",
  "เริ่มจากปุ่มเหล่านี้ก่อน",
  "  F5                 รันไฟล์/โปรเจกต์ปัจจุบัน",
  "  q หรือ Esc          ปิดหน้าผลลัพธ์และกลับไปหน้าโค้ด",
  "  i                  เข้าโหมดพิมพ์ เมื่อโปรแกรมรอรับ input",
  "  Ctrl+S             บันทึกไฟล์",
  "  Ctrl+P             ค้นหาและเปิดไฟล์",
  "  Ctrl+Shift+F       ค้นหาข้อความทั้งโปรเจกต์",
  "  Ctrl+Shift+H       ค้นหาและแทนที่ทั้งโปรเจกต์",
  "  Ctrl+/             Comment หรือ Uncomment",
  "  Alt+Shift+F        จัดรูปแบบโค้ดทั้งไฟล์",
  "  F2                 เปลี่ยนชื่อ symbol ทั้งโปรเจกต์",
  "  F12                ไปยัง definition",
  "  Ctrl+.             Quick Fix / Code Action",
  "",
  "ไฟล์และหน้าต่าง",
  "  Ctrl+N             สร้างไฟล์ใหม่",
  "  Ctrl+Shift+S       Save As",
  "  Ctrl+B             เปิด/ปิด File Explorer",
  "  Ctrl+Shift+E       แสดงไฟล์ปัจจุบันใน Explorer",
  "  Ctrl+Tab           ไปไฟล์ถัดไป",
  "  Ctrl+Shift+Tab     กลับไฟล์ก่อนหน้า",
  "  Ctrl+W             ปิดไฟล์ปัจจุบัน",
  "  Ctrl+`             เปิด/ปิด Terminal",
  "  Ctrl+Alt+Left      ย้อนกลับตำแหน่งเดิม",
  "  Ctrl+Alt+Right     เดินหน้าไปตำแหน่งถัดไป",
  "",
  "จัดการไฟล์ใน File Explorer",
  "  Enter / ลูกศรขวา   เปิดไฟล์หรือขยายโฟลเดอร์",
  "  ลูกศรซ้าย          ยุบโฟลเดอร์",
  "  Ctrl+N             สร้างไฟล์ใหม่ในโฟลเดอร์นั้น",
  "  Ctrl+Shift+N       สร้างโฟลเดอร์ใหม่",
  "  F2                 เปลี่ยนชื่อไฟล์หรือโฟลเดอร์",
  "  Delete             ย้ายไฟล์หรือโฟลเดอร์ไปถังขยะ",
  "  Ctrl+C/X/V         Copy / Cut / Paste ไฟล์",
  "  Space              เลือกหลายไฟล์",
  "  Ctrl+F             ค้นหาชื่อไฟล์ใน Explorer",
  "  F5                 Refresh รายการไฟล์",
  "  Esc                กลับไปหน้าต่างเขียนโค้ด",
  "",
  "แก้ไขข้อความ",
  "  Ctrl+A             เลือกทั้งหมด",
  "  Ctrl+C/X/V         Copy / Cut / Paste",
  "  Ctrl+Z / Ctrl+Y    Undo ทีละคำ / Redo",
  "  Ctrl+F             ค้นหาในไฟล์ปัจจุบัน",
  "  Alt+J / Alt+K      ย้ายบรรทัดหรือ selection ลง/ขึ้น",
  "",
  "เครื่องมือเขียนโค้ด",
  "  Shift+F12          ค้นหาจุดที่อ้างอิง symbol",
  "  F8 / Shift+F8     ปัญหาถัดไป / ปัญหาก่อนหน้า",
  "  F9                 เปิด/ปิด breakpoint",
  "  Tab                รับ autocomplete หรือไปช่อง snippet ถัดไป",
  "  Shift+Tab          ย้อนกลับช่อง snippet",
  "",
  "Command line (กด : ใน Normal mode)",
  "  :KeyHelp           เปิดหน้าคู่มือนี้",
  "  :Keys              ชื่อย่อของ :KeyHelp",
  "  :RunCode           รันไฟล์หรือโปรเจกต์อัตโนมัติ",
  "  :RunFile           บังคับรันไฟล์ปัจจุบัน",
  "  :RunProject        รันคำสั่งระดับโปรเจกต์",
  "  :RunClose          ปิดหน้าผลลัพธ์",
  "",
  "ปุ่ม Space คือ <leader>",
  "  Space r r          รันโค้ด (เหมือน F5)",
  "  Space r f          รันเฉพาะไฟล์",
  "  Space r p          รันโปรเจกต์",
  "  Space t r          รัน test ที่ใกล้ cursor",
  "  Space t t          รัน test ทั้งไฟล์",
  "  Space t s          เปิด/ปิดหน้ารวม tests",
  "  Space d c          เริ่ม/ทำต่อ debugger",
  "  Space d b          เปิด/ปิด breakpoint",
  "  Space g g          เปิด LazyGit ที่ root โปรเจกต์",
  "  Space x x          เปิดรายการ diagnostics ทั้งโปรเจกต์",
  "  Space u f          เปิด/ปิด format-on-save",
  "  Space u h          เปิด/ปิด inlay hints",
  "  Space ?            แสดง keymap ของหน้าปัจจุบัน",
  "",
  "กด q หรือ Esc เพื่อปิดคู่มือนี้",
}

local function open_key_help()
  local max_width = 0
  for _, line in ipairs(help_lines) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end

  local width = math.min(max_width + 2, math.max(40, vim.o.columns - 6))
  local height = math.min(#help_lines, math.max(10, vim.o.lines - 6))
  local row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1)
  local col = math.max(0, math.floor((vim.o.columns - width) / 2))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    title = " KeyHelp ",
    title_pos = "center",
    width = width,
    height = height,
    row = row,
    col = col,
  })
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, desc = "Close Key Help" })
  vim.keymap.set("n", "<esc>", close, { buffer = buf, nowait = true, desc = "Close Key Help" })
end

vim.api.nvim_create_user_command("KeyHelp", open_key_help, {
  desc = "Show the Thai IDE-style keymap guide",
})
vim.api.nvim_create_user_command("Keys", open_key_help, {
  desc = "Show the Thai IDE-style keymap guide",
})

M.open = open_key_help

return M
