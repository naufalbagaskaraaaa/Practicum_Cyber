# Lembar Soal — Praktik Mg-03: Sistem Operasi Linux & Command Line

Kelompok: 06   Kelas: TI-C4   Anggota: Zaskia Rania Zaini_(104), Naufal Bagaskara_(106), Fina Aida Purnamasari Yusuf_(128), Roisatul Ummah_(130) 

Kerjakan berurutan di dalam folder ini. Tulis jawaban singkat di bawah tiap
pertanyaan (edit file ini), dan simpan screenshot terminal ke folder `laporan/`.

Lingkungan: VM lab (Kali/Parrot/Ubuntu) atau WSL. Tidak perlu menjalankan
malware apa pun — semua tugas memakai file & perintah bawaan sistem.

---

## Bagian 1 — Navigasi & Inspeksi Filesystem (pemanasan)

1.1  Jalankan `pwd`, lalu `ls -lah`. Salin baris paling atas output `ls -lah` ke sini:
     > input: ls -lah
     > output: total 40K

1.2  Tampilkan tipe sebenarnya dari file `/bin/ls` dengan perintah `file`. Apa hasilnya?
     > input: file /bin/ls
     > output: /bin/ls: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=cfffcdd57bea0d21063e18b66ced151bd382d474, for GNU/Linux 3.2.0, stripped

1.3  Berapa banyak entri di direktori `/etc` ? (petunjuk: `ls /etc | wc -l`)
     > input: ls -a /etc | wc -l
     > output: 183

1.4  Tampilkan 5 baris pertama `/etc/os-release`. Distro & versi apa yang dipakai?
     > input: head -n 5 /etc/os-release
     > output:
     PRETTY_NAME="Kali GNU/Linux Rolling"
     NAME="Kali GNU/Linux"
     VERSION_ID="2026.2"
     VERSION="2026.2"
     VERSION_CODENAME=kali-rolling

## Bagian 2 — Permission (latihan di folder `latihan-permission/`)

Folder `latihan-permission/` berisi 3 file dengan permission yang SALAH.
Perbaiki menggunakan `chmod`, lalu buktikan dengan `ls -l`.

| File                | Kondisi sekarang | Target yang benar | Alasan |
|---------------------|------------------|-------------------|--------|
| `rahasia.txt`       | `-rw-r--r--` (644) | `-rw-------` (600) | berisi kredensial, hanya owner boleh baca |
| `skrip-publik.sh`   | `-rw-r--r--` (644) | dapat dieksekusi owner (`u+x`) | ini skrip, harus bisa dijalankan |
| `layanan.conf`      | `-rw-rw-rw-` (666) | `-rw-r--r--` (644) | world-writable = siapa pun bisa mengubah config |

2.1  Tulis perintah `chmod` yang kamu pakai untuk tiap file:
     > input: chmod 600 rahasia.txt 

     > input: chmod +x skrip-publik.sh

     > input: chmod 644 layanan.conf

2.2  Setelah diperbaiki, jalankan `ls -l latihan-permission/` dan screenshot ke `laporan/`.
     > input: ls -l latihan-permission/
     > output:
     total 16
     drwxr-xr-x 2 naufalBagaskara naufalBagaskara 4096 Sep  1 13:58 catatan
     -rw-r--r-- 1 naufalBagaskara naufalBagaskara   41 Sep  1 13:58 layanan.conf
     -rw------- 1 naufalBagaskara naufalBagaskara   58 Sep  1 13:58 rahasia.txt
     -rwxr-xr-x 1 naufalBagaskara naufalBagaskara   42 Sep  1 13:58 skrip-publik.sh

2.3  Konsep: pada sebuah DIREKTORI, apa arti bit `x` dan bit `r` ? Jelaskan singkat.
     > bit 'x' yang berarti 'execution' digunakan sistem untuk mengizinkan user untuk masuk ke dalam direktori tersebut
       dan mengakses file atau subdirektori di dalamnya jika nama berkasnya sudah diketahui sebelumnya
     > bit 'r' yang berarti 'read' digunakan sistem untuk mengizinkan pengguna untuk melihat daftar isi direktori

## Bagian 3 — User & Hak Akses

3.1  Siapa kamu sekarang? Jalankan `id`. Berapa UID & GID-mu?
     > input: id
     > output:
     uid=1000(naufalBagaskara) gid=1000(naufalBagaskara) groups=1000(naufalBagaskara),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),100(users)

3.2  Tampilkan semua akun ber-UID 0 dari `/etc/passwd`
     (petunjuk: `awk -F: '$3 == 0 {print $1}' /etc/passwd`). Ada berapa? Siapa saja?
     > input: awk -F: '$3 == 0 {print $1}' /etc/passwd
     > output: root
     > explain: jumlah akun yang memiliki UID 0 dari folder /etc/passwd adalah 1, dengan username root.

3.3  Coba `cat /etc/shadow` sebagai user biasa. Apa yang terjadi, dan mengapa?
     > input: cat /etc/shadow
     > output: cat: /etc/shadow: Permission denied
     > explain: izin untuk mengakses folder /etc/shadow sebagai user biasa ditolak dikarenakan akses belum diberikan.

3.4  Jalankan `sudo -l` (kalau diminta password, masukkan password user-mu).
     Perintah apa yang boleh kamu jalankan sebagai root?
     > input: sudo -l
     > output: 
     [sudo] password for naufalBagaskara:
     Matching Defaults entries for naufalBagaskara on LAPTOP-3MLKIL0H:
     secure_path=/usr/sbin\:/usr/bin\:/sbin\:/bin

     Runas and Command-specific defaults for naufalBagaskara:
     Defaults!/usr/sbin/visudo env_keep+="SUDO_EDITOR EDITOR VISUAL"

     User naufalBagaskara may run the following commands on LAPTOP-3MLKIL0H:
     (ALL : ALL) ALL
     > explain: Pengguna dapat menjalankan semua perintah sebagai root (karena ALL di bagian akhir menunjukkan semua perintah).

## Bagian 4 — Proses & Layanan

4.1  Tampilkan 5 proses dengan penggunaan memori terbesar
     (petunjuk: `ps aux --sort=-%mem | head -n 6`). Proses apa yang teratas?
     > input: ps aux --sort=-%mem | head -n 5
     > output:
     USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
     root         661  7.4  3.2 206640 193444 ?       DNsl 16:25   0:14 /usr/sbin/updatedb.plocate
     root           1  0.0  0.2  25156 14400 ?        Ss   16:08   0:00 /sbin/init
     root          39  0.0  0.2  50096 14400 ?        Ss   16:08   0:00 /usr/lib/systemd/systemd-journald
     naufalB+     234  0.0  0.2  23296 12800 ?        Ss   16:08   0:00 /usr/lib/systemd/systemd --user
     root          50  0.0  0.1  36132 11520 ?        Ss   16:08   0:00 /usr/lib/systemd/systemd-udevd	
     > explain: Proses PID 661 (dengan command /usr/sbin/updatedb.plocate) menggunakan memori terbesar (193444 KB), yang merupakan proses utama.

4.2  Jalankan sebuah proses di background: `sleep 300 &`. Catat PID-nya, cek dengan
     `jobs` dan `ps -p <PID>`, lalu hentikan dengan `kill <PID>`. Tulis PID di sini:
     > input: sleep 300 &
     > output: [1] 877

     > input: jobs && ps -p 877
     > output: 
	[1]+  Running                    sleep 300 &
	PID TTY          TIME CMD
	877 pts/2    00:00:00 sleep

     > input: kill 877
     > output: 
	[1]+  Terminated                 sleep 300



4.3  Pilih satu layanan yang aktif (`systemctl list-units --type=service --state=running`).
     Tampilkan statusnya dengan `systemctl status <nama>` dan 5 baris lognya dengan
     `journalctl -u <nama> -n 5`. Layanan apa yang kamu pilih?
     > input:  systemctl list-units --type=service --state=running
     > output: 
	  UNIT                     LOAD   ACTIVE SUB     DESCRIPTION
	  console-getty.service    loaded active running Console Getty
	  cron.service             loaded active running Regular background program processing daemon
	  dbus.service             loaded active running D-Bus System Message Bus
	  getty@tty1.service       loaded active running Getty on tty1
	  systemd-journald.service loaded active running Journal Service
	  systemd-logind.service   loaded active running User Login Management
	  systemd-udevd.service    loaded active running Rule-based Manager for Device Events and Files
	  user@1000.service        loaded active running User Manager for UID 1000

	Legend: LOAD   → Reflects whether the unit definition was properly loaded.
	        ACTIVE → The high-level unit activation state, i.e. generalization of SUB.
	        SUB    → The low-level unit activation state, values depend on unit type.

	8 loaded units listed.

     > explain: kami memilih layanan cron.service yang merupakan regular background program processing daemon

     > input: systemctl status cron.service && sudo journalctl -u cron.service -n 5
     > output:
     cron.service - Regular background program processing daemon
     Loaded: loaded (/usr/lib/systemd/system/cron.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-09-04 19:34:16 WIB; 1h 2min ago
     Invocation: 8ec452abfaed413889fb2b090d17e911
       Docs: man:cron(8)
     Main PID: 109 (cron)
      Tasks: 1 (limit: 6920)
     Memory: 1.5M (peak: 3.4M)
        CPU: 116ms
     CGroup: /system.slice/cron.service
             └─109 /usr/sbin/cron -f

	Warning: some journal files were not opened due to insufficient permissions.
	[sudo] password for naufalBagaskara:
	Sep 04 20:25:01 LAPTOP-3MLKIL0H CRON[969]: pam_unix(cron:session): session opened for user root(uid=0) by root(uid=0)
	Sep 04 20:25:01 LAPTOP-3MLKIL0H CRON[969]: pam_unix(cron:session): session closed for user root
	Sep 04 20:35:01 LAPTOP-3MLKIL0H CRON[994]: pam_env(cron:session): Unable to open env file: /etc/default/locale
	Sep 04 20:35:01 LAPTOP-3MLKIL0H CRON[994]: pam_unix(cron:session): session opened for user root(uid=0) by root(uid=0)
	Sep 04 20:35:01 LAPTOP-3MLKIL0H CRON[994]: pam_unix(cron:session): session closed for user root

## Bagian 5 — Penjadwalan (cron)

5.1  Tambahkan satu entri crontab user (`crontab -e`) yang menulis timestamp ke file
     tiap menit:
         `* * * * * date >> ~/latihan-cron.log`
     Tunggu 2 menit, lalu tampilkan isi `~/latihan-cron.log`. Screenshot ke `laporan/`.
     > input: crontab -e
     > explain: berhasil dialihkan ke crontab

     > input: `* * * * * date >> ~/latihan-cron.log`
     > explain: menambahkan command di baris baru tersebut, kemudian tunggu 2 menit untuk mendapatkan log-nya.

     > input: cat ~/latihan-cron.log
     > output: 
	Thu Sep  3 17:32:01 WIB 2026
	Thu Sep  3 17:33:01 WIB 2026

5.2  Hapus lagi entri itu (`crontab -e`, hapus barisnya). Verifikasi dengan `crontab -l`.
     > input: crontab -e
     > explain: hapus command `* * * * * date >> ~/latihan-cron.log`

     > input: crontab -l
     > output:
	# Edit this file to introduce tasks to be run by cron.
	#
	# Each task to run has to be defined through a single line
	# indicating with different fields when the task will be run
	# and what command to run for the task
	#
	# To define the time you can provide concrete values for
	# minute (m), hour (h), day of month (dom), month (mon),
	# and day of week (dow) or use '*' in these fields (for 'any').
	#
	# Notice that tasks will be started based on the cron's system
	# daemon's notion of time and timezones.
	#
	# Output of the crontab jobs (including errors) is sent through
	# email to the user the crontab file belongs to (unless redirected).
	#
	# For example, you can run a backup of all your user accounts
	# at 5 a.m every week with:
	# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
	#
	# For more information see the manual pages of crontab(5) and cron(8)
	#
	# m h  dom mon dow   command

	# * * * * * date >> ~/latihan-cron.log 

5.3  Konsep: sebutkan 3 lokasi cron di level sistem (bukan per-user) yang biasa
     diperiksa saat forensik untuk mencari persistence.
     > input: cat /etc/crontab
     > output: 
	/etc/cron.daily
	/etc/cron.weekly
	 /etc/cron.monthly

## Bagian 6 — Skrip Bash: "Mini Audit Keamanan Linux"

Lengkapi file `audit-keamanan.sh` (sudah ada kerangkanya di folder ini).
Skrip harus melakukan 5 pengecekan:

  1. Daftar akun ber-UID 0 — tandai bila ada selain `root`.
  2. File SUID/SGID di `/usr/bin`, `/bin`, `/sbin`.
  3. File world-writable di direktori sistem.
  4. Entri cron (user + `/etc/crontab` + `/etc/cron.d/` + `/etc/cron.*/`) —
     tandai baris yang menyebut `/tmp` atau `/dev/shm`.
  5. Nilai `PermitRootLogin` dan `PasswordAuthentication` di `/etc/ssh/sshd_config`
     (kalau OpenSSH tidak terpasang, cetak "sshd_config tidak ditemukan").

Ketentuan kode: ada shebang; minimal 1 fungsi, 1 loop, 1 kondisional; keluar dengan
exit code 0 bila tidak ada temuan berisiko, selain itu 1.

6.1  Jadikan skrip dapat dieksekusi, lalu jalankan sambil menyimpan laporan:
         `chmod +x audit-keamanan.sh`
         `./audit-keamanan.sh | tee "laporan/audit-$(date +%Y%m%d-%H%M).txt"`

	> input: chmod +x audit-keamanan.sh
	> input: ./audit-keamanan.sh | tee "laporan/audit-$(date +%Y%m%d-%H%M).txt"
	> output:
	------------------------------------------------------------
	# 1. Akun dengan UID 0 (seharusnya hanya root)
	------------------------------------------------------------
	------------------------------------------------------------
	# 2. File SUID / SGID di /usr/bin /bin /sbin
	------------------------------------------------------------
	------------------------------------------------------------
	# 3. File world-writable di direktori sistem
	------------------------------------------------------------
	------------------------------------------------------------
	# 4. Entri cron (tandai yang menyebut /tmp atau /dev/shm)
	------------------------------------------------------------
	kelompok6boss
	------------------------------------------------------------
	# 5. Konfigurasi SSH
	------------------------------------------------------------
	kelompok6boss
	------------------------------------------------------------
	# Ringkasan
	------------------------------------------------------------
	Dijalankan oleh : naufalBagaskara
	Host / tanggal  : LAPTOP-3MLKIL0H / Thu Sep  3 07:19:56 PM WIB 2026
	Total temuan berisiko: 0

6.2  Tempel di sini perintah `find` yang kamu pakai untuk mencari file SUID:
     > input: find /usr/bin -type f -perm -4000

6.3  Untuk SETIAP kategori temuan, tulis 1 paragraf: apakah ini risiko nyata di
     sistemmu? Bagaimana cara memperbaikinya? (kaitkan ke checklist hardening di materi)
     > (1) UID 0: idak ada risiko pada sistem saya karena hanya root yang memiliki UID 0. Untuk hardening, pastikan tidak ada akun lain yang menggunakan UID 0 agar hak akses root tidak disalahgunakan.
     > (2) SUID/SGID: Tidak ditemukan risiko pada hasil audit. File SUID/SGID yang tidak diperlukan sebaiknya dihapus bit-nya agar tidak dapat digunakan untuk mendapatkan akses lebih tinggi.
     > (3) world-writable: Tidak ditemukan risiko pada hasil audit. Permission file sebaiknya dibatasi agar hanya user atau grup yang membutuhkan yang dapat mengubah file.
     > (4) cron: Tidak ditemukan cron yang mencurigakan pada hasil audit. Untuk hardening, periksa cron secara berkala dan hapus job yang tidak dikenal, terutama yang menjalankan file dari /tmp atau /dev/shm.
     > (5) SSH: Tidak ditemukan risiko pada konfigurasi SSH. Untuk hardening, akses root langsung sebaiknya dinonaktifkan dan autentikasi password dapat dibatasi jika SSH key sudah digunakan.

---

### Checklist sebelum dikumpulkan (jalankan `bash cek-progress.sh`)
- [ ] SOAL.md terisi semua jawaban
- [ ] latihan-permission/ sudah diperbaiki + screenshot di laporan/
- [ ] audit-keamanan.sh berjalan tanpa error & menghasilkan file di laporan/
- [ ] laporan/ berisi screenshot Bagian 2, 4, 5, 6
- [ ] Folder ini diekspor jadi 1 PDF + disertakan file audit-keamanan.sh
