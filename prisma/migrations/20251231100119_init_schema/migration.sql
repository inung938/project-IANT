-- CreateTable
CREATE TABLE `pengguna` (
    `id_pengguna` INTEGER NOT NULL AUTO_INCREMENT,
    `username` VARCHAR(191) NULL,
    `email` VARCHAR(191) NOT NULL,
    `password` VARCHAR(191) NOT NULL,
    `jenis_kelamin` VARCHAR(191) NULL,
    `usia` INTEGER NULL,
    `berat_badan` DOUBLE NULL,
    `tinggi_badan` DOUBLE NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `tanggal_lahir` DATETIME(3) NULL,

    UNIQUE INDEX `pengguna_email_key`(`email`),
    PRIMARY KEY (`id_pengguna`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `profil` (
    `profil_id` INTEGER NOT NULL AUTO_INCREMENT,
    `id_pengguna` INTEGER NOT NULL,
    `nama` VARCHAR(191) NULL,
    `info_tentang` VARCHAR(191) NULL,
    `aktivitas_favorit` VARCHAR(191) NULL,

    UNIQUE INDEX `profil_id_pengguna_key`(`id_pengguna`),
    PRIMARY KEY (`profil_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `homeStats` (
    `stats_id` INTEGER NOT NULL AUTO_INCREMENT,
    `id_pengguna` INTEGER NOT NULL,
    `km_tempuh` DOUBLE NULL,
    `kalori_terbakar` DOUBLE NULL,
    `durasi_olahraga` INTEGER NULL,
    `langkah_harian` INTEGER NULL,
    `berat_badan` DOUBLE NULL,
    `tanggal` DATETIME(3) NULL,

    PRIMARY KEY (`stats_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `otpCode` (
    `otp_id` INTEGER NOT NULL AUTO_INCREMENT,
    `id_pengguna` INTEGER NOT NULL,
    `kode` VARCHAR(191) NOT NULL,
    `expiredAt` DATETIME(3) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `otpCode_id_pengguna_key`(`id_pengguna`),
    PRIMARY KEY (`otp_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `rencanaOlahraga` (
    `rencana_id` INTEGER NOT NULL AUTO_INCREMENT,
    `id_pengguna` INTEGER NOT NULL,
    `nama_rencana` VARCHAR(191) NULL,
    `target_km` DOUBLE NULL,
    `target_kalori` DOUBLE NULL,
    `target_durasi` INTEGER NULL,
    `target_olahraga` VARCHAR(191) NOT NULL,
    `tanggal_mulai` DATETIME(3) NOT NULL,
    `tanggal_berakhir` DATETIME(3) NOT NULL,
    `waktu_pengingat` DATETIME(3) NOT NULL,
    `hari_olahraga` TEXT NOT NULL,

    PRIMARY KEY (`rencana_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `olahraga` (
    `olahraga_id` INTEGER NOT NULL AUTO_INCREMENT,
    `id_pengguna` INTEGER NOT NULL,
    `rencana_id` INTEGER NULL,
    `jenis_olahraga` VARCHAR(191) NOT NULL,
    `total_jarak` DOUBLE NULL,
    `status` VARCHAR(191) NOT NULL,
    `tanggal_olahraga` DATETIME(3) NOT NULL,

    PRIMARY KEY (`olahraga_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `petaRute` (
    `rute_id` INTEGER NOT NULL AUTO_INCREMENT,
    `olahraga_id` INTEGER NOT NULL,
    `id_pengguna` INTEGER NOT NULL,
    `waktu_mulai` INTEGER NOT NULL,
    `waktu_selesai` INTEGER NULL,
    `jarak` DOUBLE NULL,
    `kalori_terbakar` DOUBLE NULL,
    `kecepatan_rata_rata` DOUBLE NULL,
    `koordinat_gps` LONGTEXT NOT NULL,

    UNIQUE INDEX `petaRute_olahraga_id_key`(`olahraga_id`),
    PRIMARY KEY (`rute_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `profil` ADD CONSTRAINT `profil_id_pengguna_fkey` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna`(`id_pengguna`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `homeStats` ADD CONSTRAINT `homeStats_id_pengguna_fkey` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna`(`id_pengguna`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `otpCode` ADD CONSTRAINT `otpCode_id_pengguna_fkey` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna`(`id_pengguna`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `rencanaOlahraga` ADD CONSTRAINT `rencanaOlahraga_id_pengguna_fkey` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna`(`id_pengguna`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `olahraga` ADD CONSTRAINT `olahraga_id_pengguna_fkey` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna`(`id_pengguna`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `olahraga` ADD CONSTRAINT `olahraga_rencana_id_fkey` FOREIGN KEY (`rencana_id`) REFERENCES `rencanaOlahraga`(`rencana_id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `petaRute` ADD CONSTRAINT `petaRute_olahraga_id_fkey` FOREIGN KEY (`olahraga_id`) REFERENCES `olahraga`(`olahraga_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `petaRute` ADD CONSTRAINT `petaRute_id_pengguna_fkey` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna`(`id_pengguna`) ON DELETE RESTRICT ON UPDATE CASCADE;
