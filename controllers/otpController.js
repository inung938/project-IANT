const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const nodemailer = require('nodemailer');

// === 1. KIRIM OTP DENGAN RELASI USER_ID ===
exports.otpSend = async (req, res) => {
  const { email } = req.body;

  if (!email) return res.status(400).json({ success: false, message: "Email diperlukan" });

  try {
    // Cek apakah email terdaftar di pengguna
    const user = await prisma.pengguna.findUnique({
      where: { email }
    });

    if (!user) {
      return res.status(404).json({ success: false, message: "Email tidak terdaftar" });
    }

    // Generate OTP 6 angka
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // 5 menit expired
    const expiredAt = new Date(Date.now() + 5 * 60 * 1000);

    // Hapus OTP lama jika ada berdasarkan userId
    await prisma.otpCode.deleteMany({
      where: { id_pengguna: user.id_pengguna }
    });

    // Simpan OTP baru dengan userId
    const newOtp = await prisma.otpCode.create({
      data: {
        kode: otp,
        expiredAt,
        id_pengguna: user.id_pengguna
      }
    });

    // Nodemailer transporter
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: "iantproject04@gmail.com",
        pass: "temqvcxtuoeykwgk" // app password TANPA spasi
      }
    });

    await transporter.sendMail({
      from: "IANT PROJECT <iantproject@gmail.com>",
      to: email,
      subject: "Kode Verifikasi OTP",
      text: `Kode OTP Anda: ${otp}. Berlaku 5 menit.`,
      html: `<h2>Kode OTP Anda: <b>${otp}</b></h2><p>Berlaku 5 menit.</p>`
    });

    res.status(201).json({ 
      success: true, 
      message: "OTP berhasil dikirim",
      otpCode: {
        id_pengguna: newOtp.id_pengguna,
      },
    });

  } catch (error) {
    console.error("OTP Error:", error);
    res.status(500).json({ success: false, message: "Gagal mengirim OTP" });
  }
};

// === 2. VERIFIKASI OTP DENGAN EMAIL & USER_ID ===
exports.otpVerify = async (req, res) => {
  const { userId, email, kode } = req.body;

  if (!userId || !email || !kode) {
    return res.status(400).json({ success: false, message: "userId, email & kode wajib diisi" });
  }

  try {
    // Ambil user berdasarkan userId
    const user = await prisma.pengguna.findUnique({
      where: { id_pengguna: parseInt(userId) }
    });

    if (!user) {
      return res.status(404).json({ success: false, message: "User tidak ditemukan" });
    }

    // Validasi email user
    if (user.email !== email) {
      return res.status(400).json({ success: false, message: "Email tidak sesuai dengan user" });
    }

    // Cari OTP berdasarkan userId dan kode
    const otpData = await prisma.otpCode.findFirst({
      where: { id_pengguna: user.id_pengguna, kode }
    });

    if (!otpData) {
      return res.status(400).json({ success: false, message: "Kode OTP salah" });
    }

    // Cek apakah OTP sudah expired
    if (otpData.expiredAt < new Date()) {
      return res.status(400).json({ success: false, message: "Kode OTP kadaluarsa" });
    }

    // Hapus OTP setelah berhasil diverifikasi
    await prisma.otpCode.delete({ where: { otp_id: otpData.otp_id } });

    res.json({ success: true, message: "OTP valid" });

  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Terjadi kesalahan" });
  }
};