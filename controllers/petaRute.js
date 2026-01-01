const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * ===============================
 * CREATE (POST)
 * ===============================
 */
exports.createPetaRute = async (req, res) => {
  try {
    const {
      id_pengguna,
      waktu_mulai,
      koordinat_gps,
    } = req.body;

    const data = await prisma.petaRute.create({
      data: {
        id_pengguna,
        waktu_mulai,
        koordinat_gps,
      },
    });

    res.status(201).json({
      success: true,
      message: 'Peta rute berhasil dibuat',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal membuat peta rute',
      error: error.message,
    });
  }
};

/**
 * ===============================
 * GET BY id_pengguna
 * ===============================
 */
exports.getPetaRute = async (req, res) => {
  try {
    const id_pengguna = parseInt(req.params.id_pengguna);

    const data = await prisma.petaRute.findUnique({
      where: { id_pengguna },
      include: { pengguna: true },
    });

    if (!data) {
      return res.status(404).json({
        success: false,
        message: 'Peta rute tidak ditemukan',
      });
    }

    res.json({
      success: true,
      data,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil peta rute',
      error: error.message,
    });
  }
};

/**
 * ===============================
 * UPDATE
 * ===============================
 */
exports.updatePetaRute = async (req, res) => {
  try {
    const rute_id = parseInt(req.params.rute_id); // ✅ AMBIL DARI PARAM
    const {
      waktu_mulai,
      waktu_selesai,
      jarak,
      kalori_terbakar,
      kecepatan_rata_rata,
      koordinat_gps,
    } = req.body;

    if (!rute_id) {
      return res.status(400).json({
        success: false,
        message: "rute_id wajib dikirim",
      });
    }

    const data = {};
    if (waktu_mulai !== undefined) data.waktu_mulai = waktu_mulai;
    if (waktu_selesai !== undefined) data.waktu_selesai = waktu_selesai;
    if (jarak !== undefined) data.jarak = jarak;
    if (kalori_terbakar !== undefined)
      data.kalori_terbakar = kalori_terbakar;
    if (kecepatan_rata_rata !== undefined)
      data.kecepatan_rata_rata = kecepatan_rata_rata;
    if (koordinat_gps !== undefined)
      data.koordinat_gps = koordinat_gps;

    const result = await prisma.petaRute.update({
      where: { rute_id }, // ✅ SATU-SATUNYA YANG BENAR
      data,
    });

    res.json({
      success: true,
      message: "Peta rute berhasil diperbarui",
      data: result,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Gagal memperbarui peta rute",
      error: error.message,
    });
  }
};

exports.getIdRute = async (req, res) => {
  try {
    const olahraga_id = parseInt(req.params.olahraga_id);

    const data = await prisma.olahraga.findUnique({
      where: { olahraga_id },
      include: {
        petaRute: true,
      },
    });

    if (!data) {
      return res.status(404).json({
        success: false,
        message: 'Detail olahraga tidak ditemukan',
      });
    }

    res.json({
      success: true,
      rute_id: data.petaRute.rute_id,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil detail olahraga',
      error: error.message,
    });
  }
};