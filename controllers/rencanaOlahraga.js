const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * CREATE rencana olahraga
 */
exports.createRencanaOlahraga = async (req, res) => {
  try {
    const {
      id_pengguna,
      nama_rencana,
      target_km,
      target_kalori,
      target_durasi,
      target_olahraga,
      tanggal_mulai,
      tanggal_berakhir,
      waktu_pengingat,
      hari_olahraga,
    } = req.body;

    const data = await prisma.rencanaOlahraga.create({
      data: {
        id_pengguna,
        nama_rencana,
        target_km: target_km || null,
        target_kalori: target_kalori || null,
        target_durasi: target_durasi || null,
        target_olahraga,
        tanggal_mulai: new Date(tanggal_mulai),
        tanggal_berakhir: new Date(tanggal_berakhir),
        waktu_pengingat: new Date(waktu_pengingat),
        hari_olahraga,
      },
    });

    res.status(201).json({
      success: true,
      message: 'Rencana olahraga berhasil dibuat',
      data,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Gagal membuat rencana olahraga',
      error: error.message,
    });
  }
};

/**
 * GET rencana olahraga by id_pengguna
 */
exports.getRencanaOlahraga = async (req, res) => {
  try {
    const id_pengguna = parseInt(req.params.id_pengguna);

    const rencana = await prisma.rencanaOlahraga.findFirst({
      where: { id_pengguna },
      orderBy: { rencana_id: 'desc' },
    });

    if (!rencana) {
      return res.status(200).json({
        success: true,
        rencana: null, // ⬅️ PENTING UNTUK FLUTTER
      });
    }

    return res.status(200).json({
      success: true,
      rencana,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      success: false,
      message: 'Gagal mengambil rencana olahraga',
    });
  }
};

exports.updateRencanaOlahraga = async (req, res) => {
  try {
    const rencana_id = Number(req.params.rencana_id);

    // 🔴 Validasi ID
    if (!rencana_id || isNaN(rencana_id)) {
      return res.status(400).json({
        success: false,
        message: 'rencana_id tidak valid',
      });
    }

    const {
      nama_rencana,
      target_km,
      target_kalori,
      target_durasi,
      target_olahraga,
      tanggal_mulai,
      tanggal_berakhir,
      waktu_pengingat,
      hari_olahraga,
    } = req.body;

    // 🔴 Cek data exist
    const existing = await prisma.rencanaOlahraga.findUnique({
      where: { rencana_id },
    });

    if (!existing) {
      return res.status(404).json({
        success: false,
        message: 'Rencana olahraga tidak ditemukan',
      });
    }

    const data = await prisma.rencanaOlahraga.update({
      where: { rencana_id },
      data: {
        // ⬇️ hanya update jika dikirim
        nama_rencana: nama_rencana ?? undefined,
        target_olahraga: target_olahraga ?? undefined,

        target_km:
          target_km !== undefined ? Number(target_km) : undefined,

        target_kalori:
          target_kalori !== undefined ? Number(target_kalori) : undefined,

        target_durasi:
          target_durasi !== undefined ? Number(target_durasi) : undefined,

        tanggal_mulai:
          tanggal_mulai ? new Date(tanggal_mulai) : undefined,

        tanggal_berakhir:
          tanggal_berakhir ? new Date(tanggal_berakhir) : undefined,

        waktu_pengingat:
          waktu_pengingat ? new Date(waktu_pengingat) : undefined,

        hari_olahraga:
          hari_olahraga !== undefined ? hari_olahraga : undefined,
      },
    });

    return res.json({
      success: true,
      message: 'Rencana olahraga berhasil diperbarui',
      data,
    });
  } catch (error) {
    console.error("UPDATE RENCANA ERROR:", error);

    return res.status(500).json({
      success: false,
      message: 'Gagal memperbarui rencana olahraga',
      error: error.message,
    });
  }
};

/**
 * DELETE rencana olahraga by rencana_id
 */
exports.deleteRencanaOlahraga = async (req, res) => {
  try {
    const rencana_id = parseInt(req.params.rencana_id);

    if (!rencana_id) {
      return res.status(400).json({
        success: false,
        message: "rencana_id wajib diisi",
      });
    }

    await prisma.rencanaOlahraga.delete({
      where: { rencana_id },
    });

    res.json({
      success: true,
      message: "Rencana olahraga berhasil dibatalkan",
    });
  } catch (error) {
    console.error("Delete Rencana Error:", error);
    res.status(500).json({
      success: false,
      message: "Gagal membatalkan rencana olahraga",
    });
  }
};
