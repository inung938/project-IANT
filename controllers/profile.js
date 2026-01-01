const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// ===== UPDATE PROFIL (username, nama, tanggal lahir, jenis kelamin, info_tentang) =====
exports.updateProfile = async (req, res) => {
  const {
    id_pengguna,
    username,
    nama,
    tanggal_lahir,
    jenis_kelamin,
    tinggi_badan,
    berat_badan,
    info_tentang,
    aktivitas_favorit,
  } = req.body;

  if (!id_pengguna) {
    return res
      .status(400)
      .json({ success: false, message: 'ID pengguna wajib dikirim' });
  }

  try {
    // 1. Cek apakah pengguna ada + profil-nya
    const user = await prisma.pengguna.findUnique({
      where: { id_pengguna: Number(id_pengguna) },
      include: { profil: true },
    });

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: 'Pengguna tidak ditemukan' });
    }

    // 2. Siapkan object untuk update
    const dataUpdate = {}; // untuk tabel pengguna
    const dataProfil = {}; // untuk tabel profil

    // ----- PENGGUNA -----
    if (username !== undefined && username !== null && username !== '') {
      dataUpdate.username = username;
    }

    if (jenis_kelamin !== undefined && jenis_kelamin !== null && jenis_kelamin !== '') {
      dataUpdate.jenis_kelamin = jenis_kelamin;
    }

    if (tinggi_badan !== undefined && tinggi_badan !== null && tinggi_badan !== '') {
      dataUpdate.tinggi_badan = tinggi_badan;
    }

    if (berat_badan !== undefined && berat_badan !== null && berat_badan !== '') {
      dataUpdate.berat_badan = berat_badan;
    }

    // Jika tanggal lahir dikirim → hitung usia
    if (tanggal_lahir) {
      const birthDate = new Date(tanggal_lahir);
      const today = new Date();
      let usia = today.getFullYear() - birthDate.getFullYear();
      const m = today.getMonth() - birthDate.getMonth();
      if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) usia--;

      // pastikan kolom2 ini memang ada di model Prisma-mu
      dataUpdate.tanggal_lahir = birthDate;
      dataUpdate.usia = usia;
    }

    // ----- PROFIL -----
    if (nama !== undefined && nama !== null && nama !== '') {
      dataProfil.nama = nama;
    }

    if (info_tentang !== undefined && info_tentang !== null && info_tentang !== '') {
      dataProfil.info_tentang = info_tentang;
    }

    if (aktivitas_favorit !== undefined && aktivitas_favorit !== null && aktivitas_favorit !== '') {
      dataProfil.aktivitas_favorit = aktivitas_favorit;
    }

    // 3. Update tabel pengguna (kalau ada yang diupdate)
    let updatedPengguna = user;
    if (Object.keys(dataUpdate).length > 0) {
      updatedPengguna = await prisma.pengguna.update({
        where: { id_pengguna: Number(id_pengguna) },
        data: dataUpdate,
      });
    }

    // 4. Tangani tabel profil hanya kalau ADA dataProfil yang mau diubah
    let updatedProfil = user.profil;

    if (Object.keys(dataProfil).length > 0) {
      // kalau profil belum ada → buat
      if (!user.profil) {
        updatedProfil = await prisma.profil.create({
          data: {
            id_pengguna: Number(id_pengguna),
            ...dataProfil, // hanya field yang dikirim, tidak mengosongkan yang lain
          },
        });
      } else {
        // profil sudah ada → update field tertentu saja
        updatedProfil = await prisma.profil.update({
          where: { id_pengguna: Number(id_pengguna) },
          data: dataProfil,
        });
      }
    }

    // 5. Response
    return res.status(200).json({
      success: true,
      message: 'Profil berhasil diperbarui',
      pengguna: updatedPengguna,
      profil: updatedProfil,
    });
  } catch (error) {
    console.error('❌ Update Profil Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal memperbarui profil',
    });
  }
};

// ===== GET PROFIL LENGKAP =====
exports.getProfile = async (req, res) => {
  const { id_pengguna } = req.params; // dari query ?id_pengguna=1

  if (!id_pengguna) {
    return res.status(400).json({
      success: false,
      message: "id_pengguna wajib dikirim",
    });
  }

  try {
    const pengguna = await prisma.pengguna.findUnique({
      where: { id_pengguna: Number(id_pengguna) },
      include: { profil: true },
    });

    if (!pengguna) {
      return res.status(404).json({
        success: false,
        message: "Pengguna tidak ditemukan",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Data profil berhasil diambil",
      data: {
        pengguna: {
          id_pengguna: pengguna.id_pengguna,
          username: pengguna.username,
          jenis_kelamin: pengguna.jenis_kelamin,
          tanggal_lahir: pengguna.tanggal_lahir,
          usia: pengguna.usia,
          email: pengguna.email, // kalau ada di DB
          berat_badan: pengguna.berat_badan, // kalau ada di DB
          tinggi_badan: pengguna.tinggi_badan, // kalau ada di DB
        },
        profil: pengguna.profil || null, // tetap null jika belum ada
      },
    });
  } catch (error) {
    console.error("❌ GET PROFIL ERROR:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal mengambil data profil",
    });
  }
};