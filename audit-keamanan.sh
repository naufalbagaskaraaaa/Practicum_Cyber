#!/usr/bin/env bash
#
# audit-keamanan.sh — Mini Audit Keamanan Linux (Bagian 6, Lab Mg-03)
# Kelompok: 6    Kelas: TI-C4
#
# Jalankan:
#   chmod +x audit-keamanan.sh
#   ./audit-keamanan.sh | tee "laporan/audit-$(date +%Y%m%d-%H%M).txt"
#
# Lengkapi setiap fungsi bertanda TODO.
# Syarat: shebang (sudah ada) + minimal 1 fungsi + 1 loop + 1 kondisional.
# Exit code: 0 bila tidak ada temuan berisiko, selain itu 1.

set -u
TEMUAN=0    # naikkan (TEMUAN=$((TEMUAN+1))) tiap menemukan hal berisiko

garis() { printf -- '------------------------------------------------------------\n'; }
judul() { garis; printf '# %s\n' "$1"; garis; }

# --------------------------------------------------------------------------- 1
cek_uid0() {
  judul "1. Akun dengan UID 0 (seharusnya hanya root)"
  # TODO:
  #   - baca /etc/passwd, tampilkan tiap akun ber-UID 0
  #   - contoh: awk -F: '$3 == 0 { print $1 }' /etc/passwd
  #   - kalau ada nama selain "root": cetak "[!] ..." dan TEMUAN=$((TEMUAN+1))

  user_uid0=$(awk -F: '$3 == 0 { print $1 }' /etc/passwd)

  echo "User dengan UID 0:"
  echo "$user_uid0"

  for user in $user_uid0; do
    if [ "$user" != "root" ]; then
      echo "resiko ditemukan, username '$user' memiliki UID 0"
      TEMUAN=$((TEMUAN+1))
    fi
  done

  if [ "$user_uid0" = "root" ]; then
    echo "tidak menemukan risiko."
  fi
}

# --------------------------------------------------------------------------- 2
cek_suid() {
  judul "2. File SUID / SGID di /usr/bin /bin /sbin"
  # TODO: pakai find dengan -perm -4000 (SUID) dan -perm -2000 (SGID)
  #       loop di beberapa direktori, mis:  for d in /usr/bin /bin /sbin; do ... done
  for d in /usr/bin /bin /sbin; do
    if [ -d "$d" ]; then
      echo "mencari pada direktori $d ..."
      suid_files=$(find "$d" -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null)
      
      if [ -z "$suid_files" ]; then
        echo "tidak ditemukan file SUID/SGID."
      else
        for file in $suid_files; do
          echo " file ditemukan: $file"
        done
      fi
    fi
  done
}

# --------------------------------------------------------------------------- 3
cek_world_writable() {
  judul "3. File world-writable di direktori sistem"
  # TODO: find /etc /usr /bin /sbin -xdev -type f -perm -0002 2>/dev/null
  echo "memindai folder /etc /usr /bin /sbin"
  ww_files=$(find /etc /usr /bin /sbin -xdev -type f -perm -0002 2>/dev/null)
  if [ -z "$ww_files" ]; then
    echo "tidak ditemukan file world-writable."
  else
    for file in $ww_files; do
      echo "file tersebut berisiko (world-writable): $file"
      TEMUAN=$((TEMUAN+1))
    done
  fi
}

# --------------------------------------------------------------------------- 4
cek_cron() {
  judul "4. Entri cron, tandai yang menyebut /tmp atau /dev/shm"
  # TODO:
  #   - crontab -l 2>/dev/null
  #   - isi /etc/crontab, /etc/cron.d/*, /etc/cron.daily/* dst.
  #   - kalau sebuah baris mengandung /tmp atau /dev/shm -> tandai + TEMUAN++
  echo "cek crontab user aktif"
  if crontab -l 2>/dev/null | grep -qE '/tmp|/dev/shm'; then
    echo "crontab user memuat eksekusi dari /tmp atau /dev/shm"
    TEMUAN=$((TEMUAN+1))
  else
    echo "tidak mengadung /tmp dan atau /dev/shm"
  fi

  echo "cek direktori cron sistem"
  sys_cron=$(find /etc/crontab /etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly -type f 2>/dev/null)
  local cron_temuan=0
  for file in $sys_cron; do
    if grep -qE '/tmp|/dev/shm' "$file" 2>/dev/null; then
      echo "file $file memuat path berisiko (/tmp atau /dev/shm)!"
      TEMUAN=$((TEMUAN+1))
      cron_temuan=1
    fi
  done
  
  if [ "$cron_temuan" -eq 0 ]; then
     echo "tidak ada entri cron sistem berisiko."
  fi
}

# --------------------------------------------------------------------------- 5
cek_ssh() {
  judul "5. Konfigurasi SSH"
  local cfg="/etc/ssh/sshd_config"
  # TODO:
  #   - kalau file $cfg tidak ada -> cetak pesan, return
  #   - kalau ada -> tampilkan nilai PermitRootLogin & PasswordAuthentication
  #   - kalau PermitRootLogin = yes  ATAU  PasswordAuthentication = yes -> TEMUAN++
   local cfg="/etc/ssh/sshd_config"
  
  if [ ! -f "$cfg" ]; then
    echo "file $cfg tidak ditemukan"
    return
  fi

  echo "memeriksa $cfg ..."
  local prl=$(grep -i '^PermitRootLogin' "$cfg" | awk '{print $2}')
  local pa=$(grep -i '^PasswordAuthentication' "$cfg" | awk '{print $2}')
  
  if [ -z "$prl" ] && [ -z "$pa" ]; then
    echo "konfigurasi menggunakan nilai bawaan (default)."
  else
    if [ -n "$prl" ]; then
      echo "  - PermitRootLogin = $prl"
      if [ "$(echo "$prl" | tr '[:upper:]' '[:lower:]')" = "yes" ]; then
        echo "ditemukan kerentanan"
        TEMUAN=$((TEMUAN+1))
      fi
    fi

    if [ -n "$pa" ]; then
      echo "  - PasswordAuthentication = $pa"
      if [ "$(echo "$pa" | tr '[:upper:]' '[:lower:]')" = "yes" ]; then
        echo "ditemukan kerentanan"
        TEMUAN=$((TEMUAN+1))
      fi
    fi
  fi
}

# --------------------------------------------------------------------------- ringkasan
ringkasan() {
  judul "soon"
  printf 'Dijalankan oleh : %s\n' "$(whoami)"
  printf 'Host / tanggal  : %s / %s\n' "$(hostname)" "$(date)"
  printf 'Total temuan berisiko: %d\n' "$TEMUAN"
}

main() {
  cek_uid0
  cek_suid
  cek_world_writable
  cek_cron
  cek_ssh
  ringkasan
  if [ "$TEMUAN" -gt 0 ]; then
    exit 1
  fi
  exit 0
}

main "$@"
