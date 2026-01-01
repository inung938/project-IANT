const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');  // untuk enkripsi password
const prisma = new PrismaClient();

// REGISTER USER
exports.registerUser = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password)
    return res.status(400).json({ msg: "Data tidak lengkap"});

  try {
    // Cek apakah email sudah terdaftar
    const existingUser = await prisma.pengguna.findUnique({
      where: { email },
    });
    if (existingUser) {
      return res.status(400).json({ message: 'Email sudah terdaftar' });
    }

    // Hash password sebelum disimpan
    const hashedPassword = await bcrypt.hash(password, 10);

    // Simpan user ke database
    const newUser = await prisma.pengguna.create({
      data: {
        email,
        password: hashedPassword,
      },
    });

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      pengguna: {
        id_pengguna: newUser.id_pengguna,
        email: newUser.email,
        password: newUser.password,
        createdAt: newUser.createdAt,
      },
    });
  } catch (error) {
    console.error('❌ Register Error:', error);
    res.status(500).json({ message: 'Error registering user' });
  }
};

// LOGIN USER
exports.loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Cek apakah user ada
    const user = await prisma.pengguna.findUnique({
      where: { email },
    });

    if (!user) {
      return res.status(404).json({ success: false, message: 'Email tidak ditemukan' });
    }

    // Cek password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Password salah' });
    }

    // Login sukses
    res.json({
      success: true,
      message: 'Login berhasil',
      pengguna: {
        id_pengguna: user.id_pengguna,
        email: user.email,
        username: user.username,
      },
    });

  } catch (err) {
    console.error('❌ Login Error:', err);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan server' });
  }
};

// === RESET PASSWORD ===
exports.resetPassword = async (req, res) => {
  try {
    const { userId, email, password } = req.body;

    // 1. Validasi input
    if (!userId || !email || !password) {
      return res
        .status(400)
        .json({ success: false, message: 'userId, email, dan password wajib diisi' });
    }

    if (password.length < 6) {
      return res
        .status(400)
        .json({ success: false, message: 'Password minimal 6 karakter' });
    }

    // 2. Cari user berdasarkan ID
    const user = await prisma.pengguna.findUnique({
      where: { id_pengguna: Number(userId) },
    });

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: 'Pengguna tidak ditemukan' });
    }

    // 3. Cocokkan email
    if (user.email !== email) {
      return res
        .status(400)
        .json({ success: false, message: 'Email tidak sesuai dengan akun' });
    }

    // (OPSIONAL) 4. Bisa tambahkan cek flag "verified by OTP" kalau kamu simpan di DB
    // if (!user.isOtpVerified) { ... }

    // 5. Hash password baru
    const hashedPassword = await bcrypt.hash(password, 10);

    // 6. Update password di database
    const updatedUser = await prisma.pengguna.update({
      where: { id_pengguna: Number(userId) },
      data: {
        password: hashedPassword,
      },
      select: {
        id_pengguna: true,
        email: true,
        // jangan kirim password ke client
      },
    });

    // 7. Response sukses
    return res.status(200).json({
      success: true,
      message: 'Password berhasil diubah',
      pengguna: updatedUser,
    });
  } catch (error) {
    console.error('❌ Reset Password Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengubah password',
    });
  }
};
