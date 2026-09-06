#!/usr/bin/env bash
# Pengecek kelengkapan sebelum dikumpulkan. Tidak menilai isi, hanya keberadaan.
set -u
pass=0; fail=0
chk() { if eval "$2"; then printf '  [OK]  %s\n' "$1"; pass=$((pass+1));
        else printf '  [--]  %s\n' "$1"; fail=$((fail+1)); fi; }

# permission dalam oktal — portabel GNU (Linux/WSL) & BSD (macOS)
perm() { stat -c '%a' "$1" 2>/dev/null || stat -f '%Lp' "$1" 2>/dev/null; }

echo "== Cek kelengkapan Lab Mg-03 =="
chk "audit-keamanan.sh sudah diedit (tidak ada lagi 'echo \"TODO\"')" \
    '! grep -q "echo \"TODO\"" audit-keamanan.sh'
chk "audit-keamanan.sh dapat dieksekusi (chmod +x)" '[ -x audit-keamanan.sh ]'
chk "ada minimal 1 file laporan hasil audit di laporan/" \
    'ls laporan/audit-*.txt >/dev/null 2>&1'
chk "ada minimal 3 screenshot di laporan/" \
    '[ "$(ls laporan/ 2>/dev/null | grep -Eiv "^audit-.*\.txt$" | wc -l)" -ge 3 ]'
chk "SOAL.md: minimal 14 baris jawaban ('> ...') sudah diisi" \
    '[ "$(grep -Ec "^[[:space:]]*>[[:space:]]+\S" SOAL.md)" -ge 14 ]'
chk "latihan-permission/rahasia.txt sudah 600" \
    '[ "$(perm latihan-permission/rahasia.txt)" = "600" ]'
chk "latihan-permission/layanan.conf sudah 644" \
    '[ "$(perm latihan-permission/layanan.conf)" = "644" ]'
chk "latihan-permission/skrip-publik.sh sudah executable" \
    '[ -x latihan-permission/skrip-publik.sh ]'

echo
printf 'Selesai: %d OK, %d belum.\n' "$pass" "$fail"
[ "$fail" -eq 0 ] && echo "Siap dikumpulkan." || echo "Masih ada yang perlu dilengkapi."
