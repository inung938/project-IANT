const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

// === CREATE HOME STATS ===
exports.createHomeStats = async (req, res) => {
  const {
    id_pengguna,
    km_tempuh,
    kalori_terbakar,
    durasi_olahraga,
    langkah_harian,
    berat_badan,
    tanggal
  } = req.body;

  if (!id_pengguna) {
    return res.status(400).json({ success: false, message: "id_pengguna wajib diisi" });
  }

  try {
    // Cek apakah user ada
    const user = await prisma.pengguna.findUnique({ where: { id_pengguna } });
    if (!user) {
      return res.status(404).json({ success: false, message: "Pengguna tidak ditemukan" });
    }

    // Buat homeStats
    const homeStats = await prisma.homeStats.create({
      data: {
        id_pengguna,
        km_tempuh,
        kalori_terbakar,
        durasi_olahraga,
        langkah_harian,
        berat_badan,
        tanggal: tanggal ? new Date(tanggal) : new Date()
      }
    });

    res.json({ success: true, message: "HomeStats berhasil dibuat", data: homeStats });

  } catch (error) {
    console.error("Create HomeStats Error:", error);
    res.status(500).json({ success: false, message: "Terjadi kesalahan" });
  }
};

// === GET HOME STATS BY USER ===
exports.getHomeStats = async (req, res) => {
  const { id_pengguna } = req.params;
  const { tanggal } = req.query; // yyyy-mm-dd

  if (!tanggal) {
    return res.status(400).json({
      success: false,
      message: "tanggal wajib diisi",
    });
  }

  const start = new Date(`${tanggal}T00:00:00.000Z`);
  const end = new Date(`${tanggal}T23:59:59.999Z`);

  try {
    const homeStats = await prisma.homeStats.findFirst({
      where: {
        id_pengguna: parseInt(id_pengguna),
        tanggal: {
          gte: start,
          lte: end,
        },
      },
    });

    res.json({
      success: true,
      data: homeStats ?? {
        km_tempuh: 0,
        kalori_terbakar: 0,
        durasi_olahraga: 0,
        langkah_harian: 0,
        berat_badan: null,
      },
    });
  } catch (error) {
    console.error("Get HomeStats Error:", error);
    res.status(500).json({ success: false, message: "Terjadi kesalahan" });
  }
};

exports.updateHomeStats = async (req, res) => {
  const { id_pengguna } = req.params;
  const {
    km_tempuh = 0,
    kalori_terbakar = 0,
    durasi_olahraga = 0,
    langkah_harian = 0,
    berat_badan,
    tanggal,
  } = req.body;

  if (!tanggal) {
    return res.status(400).json({
      success: false,
      message: "tanggal wajib diisi (yyyy-mm-dd)",
    });
  }

  try {
    const userId = parseInt(id_pengguna);

    // ✅ RANGE HARI (AMAN TIMEZONE)
    const start = new Date(`${tanggal}T00:00:00`);
    const end   = new Date(`${tanggal}T23:59:59.999`);

    const existing = await prisma.homeStats.findFirst({
      where: {
        id_pengguna: userId,
        tanggal: {
          gte: start,
          lte: end,
        },
      },
    });

    let result;

    if (existing) {
      // 🔁 UPDATE (AKUMULASI)
      result = await prisma.homeStats.update({
        where: { stats_id: existing.stats_id },
        data: {
          km_tempuh: { increment: km_tempuh },
          kalori_terbakar: { increment: kalori_terbakar },
          durasi_olahraga: { increment: durasi_olahraga },
          langkah_harian: { increment: langkah_harian },
          berat_badan: berat_badan ?? undefined,
        },
      });
    } else {
      // ➕ CREATE HARI BARU
      result = await prisma.homeStats.create({
        data: {
          id_pengguna: userId,
          km_tempuh,
          kalori_terbakar,
          durasi_olahraga,
          langkah_harian,
          berat_badan,
          tanggal: start,
        },
      });
    }

    res.json({
      success: true,
      message: "HomeStats berhasil diperbarui",
      data: result,
    });
  } catch (error) {
    console.error("Update HomeStats Error:", error);
    res.status(500).json({ success: false, message: "Terjadi kesalahan" });
  }
};

// === CREATE HOME STATS (PER HARI) ===
exports.createHomeStatsPerhari = async (req, res) => {
  const { id_pengguna, tanggal } = req.body;

  if (!id_pengguna) {
    return res.status(400).json({
      success: false,
      message: "id_pengguna wajib diisi",
    });
  }

  try {
    // 1️⃣ cek user
    const user = await prisma.pengguna.findUnique({
      where: { id_pengguna },
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "Pengguna tidak ditemukan",
      });
    }

    // 2️⃣ tentukan tanggal (yyyy-mm-dd)
    const date = tanggal
      ? new Date(tanggal)
      : new Date();

    const startOfDay = new Date(date.setHours(0, 0, 0, 0));
    const endOfDay = new Date(date.setHours(23, 59, 59, 999));

    // 3️⃣ cek HomeStats hari ini
    const existing = await prisma.homeStats.findFirst({
      where: {
        id_pengguna,
        tanggal: {
          gte: startOfDay,
          lte: endOfDay,
        },
      },
    });

    // ✅ JIKA SUDAH ADA → KEMBALIKAN
    if (existing) {
      return res.json({
        success: true,
        message: "HomeStats sudah ada",
        data: existing,
      });
    }

    // 4️⃣ JIKA BELUM → BUAT BARU
    const homeStats = await prisma.homeStats.create({
      data: {
        id_pengguna,
        km_tempuh: 0,
        kalori_terbakar: 0,
        durasi_olahraga: 0,
        langkah_harian: 0,
        berat_badan: 0,
        tanggal: new Date(),
      },
    });

    res.status(201).json({
      success: true,
      message: "HomeStats berhasil dibuat",
      data: homeStats,
    });

  } catch (error) {
    console.error("Create HomeStats Error:", error);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan",
    });
  }
};

exports.getKaloriHistory = async (req, res) => {
  try {
    const userId = parseInt(req.params.id_pengguna);
    const filter = req.query.filter || "day";

    const now = new Date();
    let startDate;

    // ================= FILTER LOGIC =================
    if (filter === "day") {
      startDate = new Date(
        now.getFullYear(),
        now.getMonth(),
        now.getDate()
      );
    } 
    else if (filter === "week") {
      startDate = new Date();
      startDate.setDate(now.getDate() - 6); // 7 hari terakhir
    } 
    else if (filter === "month") {
      startDate = new Date(
        now.getFullYear(),
        now.getMonth(),
        1
      );
    } 
    else {
      return res.status(400).json({
        success: false,
        message: "Filter tidak valid",
      });
    }

    // ================= QUERY DATABASE =================
    const stats = await prisma.homeStats.findMany({
      where: {
        id_pengguna: userId,
        tanggal: {
          gte: startDate,
        },
      },
      orderBy: {
        tanggal: "asc",
      },
      select: {
        tanggal: true,
        kalori_terbakar: true,
      },
    });

    // ================= FORMAT RESPONSE =================
    const data = stats.map((item) => ({
      tanggal: item.tanggal,
      kalori_terbakar: item.kalori_terbakar ?? 0,
    }));

    return res.json({
      success: true,
      data,
    });
  } catch (error) {
    console.error("getKaloriHistory error:", error);
    return res.status(500).json({
      success: false,
      message: "Gagal mengambil data kalori",
    });
  }
};

exports.getLangkahHistory = async (req, res) => {
  try {
    const { userId } = req.params; // ✅ BENAR
    const { filter = "day" } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId wajib diisi",
      });
    }

    const id_pengguna = parseInt(userId); // ✅ WAJIB INT

    // ===============================
    // HITUNG RENTANG TANGGAL
    // ===============================
    const now = new Date();
    let startDate;

    if (filter === "day") {
      startDate = new Date(now);
      startDate.setHours(0, 0, 0, 0);
    } else if (filter === "week") {
      startDate = new Date(now);
      startDate.setDate(now.getDate() - 6);
      startDate.setHours(0, 0, 0, 0);
    } else if (filter === "month") {
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
    } else {
      return res.status(400).json({
        success: false,
        message: "filter harus day | week | month",
      });
    }

    // ===============================
    // QUERY DATABASE
    // ===============================
    const result = await prisma.homeStats.findMany({
      where: {
        id_pengguna, // ✅ sekarang VALID
        tanggal: {
          gte: startDate,
        },
      },
      orderBy: {
        tanggal: "asc",
      },
      select: {
        langkah_harian: true,
        tanggal: true,
      },
    });

    // ===============================
    // FORMAT RESPONSE
    // ===============================
    const data = result.map((item) => ({
      langkah: item.langkah_harian ?? 0,
      tanggal: item.tanggal,
    }));

    res.json({
      success: true,
      data,
    });
  } catch (error) {
    console.error("Get Langkah History Error:", error);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server",
    });
  }
};

exports.getJarakHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const { filter = "day" } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId wajib diisi",
      });
    }

    const id_pengguna = parseInt(userId);
    const now = new Date();
    let startDate;

    if (filter === "day") {
      startDate = new Date(now.setHours(0, 0, 0, 0));
    } else if (filter === "week") {
      startDate = new Date();
      startDate.setDate(now.getDate() - 6);
      startDate.setHours(0, 0, 0, 0);
    } else if (filter === "month") {
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
    }

    const result = await prisma.homeStats.findMany({
      where: {
        id_pengguna,
        tanggal: { gte: startDate },
      },
      orderBy: { tanggal: "asc" },
      select: {
        km_tempuh: true,
        tanggal: true,
      },
    });

    const data = result.map((item) => ({
      jarak: item.km_tempuh ?? 0,
      tanggal: item.tanggal,
    }));

    res.json({ success: true, data });
  } catch (err) {
    console.error("Get Jarak History Error:", err);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server",
    });
  }
};

exports.getDurasiHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const { filter = "day" } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "userId wajib diisi",
      });
    }

    const id_pengguna = parseInt(userId);
    const now = new Date();
    let startDate;

    if (filter === "day") {
      startDate = new Date(now.setHours(0, 0, 0, 0));
    } else if (filter === "week") {
      startDate = new Date();
      startDate.setDate(now.getDate() - 6);
      startDate.setHours(0, 0, 0, 0);
    } else if (filter === "month") {
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
    }

    const result = await prisma.homeStats.findMany({
      where: {
        id_pengguna,
        tanggal: { gte: startDate },
      },
      orderBy: { tanggal: "asc" },
      select: {
        durasi_olahraga: true,
        tanggal: true,
      },
    });

    const data = result.map((item) => ({
      durasi: item.durasi_olahraga ?? 0,
      tanggal: item.tanggal,
    }));

    res.json({ success: true, data });
  } catch (error) {
    console.error("Get Durasi History Error:", error);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server",
    });
  }
};

exports.saveBeratBadan = async (req, res) => {
  try {
    const { userId } = req.params;
    const { berat_badan, tanggal } = req.body;

    if (!userId || !berat_badan || !tanggal) {
      return res.status(400).json({
        success: false,
        message: "Data tidak lengkap",
      });
    }

    const id_pengguna = parseInt(userId);

    const date = new Date(tanggal);
    date.setHours(0, 0, 0, 0);

    const existing = await prisma.homeStats.findFirst({
      where: { id_pengguna, tanggal: date },
    });

    let result;

    if (existing) {
      result = await prisma.homeStats.update({
        where: { stats_id: existing.stats_id },
        data: { berat_badan },
      });
    } else {
      result = await prisma.homeStats.create({
        data: {
          id_pengguna,
          berat_badan,
          tanggal: date,
        },
      });
    }

    res.json({ success: true, data: result });
  } catch (error) {
    console.error("Save Berat Badan Error:", error);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server",
    });
  }
};

exports.getBeratBadanHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const { filter = "day" } = req.query;

    const id_pengguna = parseInt(userId);
    const now = new Date();
    let startDate;

    if (filter === "day") {
      startDate = new Date(now.setHours(0, 0, 0, 0));
    } else if (filter === "week") {
      startDate = new Date();
      startDate.setDate(now.getDate() - 6);
      startDate.setHours(0, 0, 0, 0);
    } else {
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
    }

    const result = await prisma.homeStats.findMany({
      where: {
        id_pengguna,
        tanggal: { gte: startDate },
        berat_badan: { not: null },
      },
      orderBy: { tanggal: "asc" },
      select: {
        stats_id: true,
        berat_badan: true,
        tanggal: true,
      },
    });

    res.json({
      success: true,
      data: result.map((r) => ({
        stats_id: r.stats_id,
        berat: r.berat_badan,
        tanggal: r.tanggal,
      })),
    });
  } catch (error) {
    console.error("Get Berat Badan History Error:", error);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server",
    });
  }
};

// PUT /api/home-stats/berat/:statsId
exports.updateBeratBadan = async (req, res) => {
  try {
    const { statsId } = req.params;
    const { berat_badan } = req.body;

    if (!berat_badan) {
      return res.status(400).json({
        success: false,
        message: "berat_badan wajib diisi",
      });
    }

    const result = await prisma.homeStats.update({
      where: {
        stats_id: parseInt(statsId),
      },
      data: {
        berat_badan,
      },
    });

    res.json({
      success: true,
      message: "Berat badan berhasil diperbarui",
      data: result,
    });
  } catch (error) {
    console.error("Update Berat Badan Error:", error);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server",
    });
  }
};
