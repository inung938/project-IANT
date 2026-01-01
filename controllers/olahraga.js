const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * POST olahraga + peta rute
 */
exports.createOlahraga = async (req, res) => {
  try {
    const {
      id_pengguna,
      jenis_olahraga,
      total_jarak,
      status,
      tanggal_olahraga,
      waktu_mulai,
      waktu_selesai,
      jarak,
      kalori_terbakar,
      kecepatan_rata_rata,
      koordinat_gps,
    } = req.body;

    // 1️⃣ Ambil rencana terakhir user (jika ada)
    const rencana = await prisma.rencanaOlahraga.findFirst({
      where: {
        id_pengguna,
        // opsional: hanya rencana aktif
        tanggal_berakhir: { gte: new Date() }
      },
      orderBy: {
        rencana_id: 'desc',
      },
    });

    const olahraga = await prisma.olahraga.create({
      data: {
        id_pengguna,
        rencana_id: rencana ? rencana.rencana_id : null,
        jenis_olahraga,
        status,
        total_jarak,
        tanggal_olahraga: new Date(tanggal_olahraga),
        petaRute: {
          create: {
            id_pengguna,
            waktu_mulai,
            waktu_selesai,
            jarak,
            kalori_terbakar,
            kecepatan_rata_rata,
            koordinat_gps,
          },
        },
      },
      include: {
        petaRute: true,
      },
    });

    res.status(201).json({
      success: true,
      message: 'Olahraga berhasil disimpan',
      data: olahraga,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal menyimpan olahraga',
      error: error.message,
    });
  }
};

/**
 * GET olahraga by id_pengguna
 */
exports.getOlahragaByUser = async (req, res) => {
  try {
    const id_pengguna = parseInt(req.params.id_pengguna);

    const data = await prisma.olahraga.findMany({
      where: { id_pengguna },
      include: {
        petaRute: true,
      },
      orderBy: {
        tanggal_olahraga: 'desc',
      },
    });

    if (data.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Data olahraga tidak ditemukan',
      });
    }

    res.json({
      success: true,
      data,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil data olahraga',
      error: error.message,
    });
  }
};

/**
 * GET detail olahraga by olahraga_id
 */
exports.getDetailOlahraga = async (req, res) => {
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
      data,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal mengambil detail olahraga',
      error: error.message,
    });
  }
};

/**
 * PUT update olahraga + peta rute
 */
exports.updateOlahraga = async (req, res) => {
  try {
    const olahraga_id = parseInt(req.params.olahraga_id);

    const {
      jenis_olahraga,
      status,
      total_jarak,
      tanggal_olahraga,
      waktu_mulai,
      waktu_selesai,
      jarak,
      kalori_terbakar,
      kecepatan_rata_rata,
      koordinat_gps,
    } = req.body;

    const data = await prisma.olahraga.update({
      where: { olahraga_id },
      data: {
        jenis_olahraga,
        total_jarak,
        status,
        tanggal_olahraga: tanggal_olahraga
          ? new Date(tanggal_olahraga)
          : undefined,
        petaRute: {
          update: {
            waktu_mulai,
            waktu_selesai,
            jarak,
            kalori_terbakar,
            kecepatan_rata_rata,
            koordinat_gps,
          },
        },
      },
      include: {
        petaRute: true,
      },
    });

    res.json({
      success: true,
      message: 'Olahraga berhasil diperbarui',
      data,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal memperbarui olahraga',
      error: error.message,
    });
  }
};