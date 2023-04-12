USE master
ALTER DATABASE KTP SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE KTP

CREATE DATABASE KTP
ON PRIMARY 
   (NAME = KTP_data, 
    FILENAME = '/Users/ayash/Database/Database_KTP/KTP_data.mdf', 
    SIZE = 100MB, 
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 10MB), 
FILEGROUP SecondaryGroup
   (NAME = KTP_secondary, 
    FILENAME = '/Users/ayash/Database/Database_KTP/KTP_secondary.ndf', 
    SIZE = 170MB, 
    MAXSIZE = UNLIMITED, 
    FILEGROWTH = 5MB)
LOG ON 
   (NAME = KTP_log, 
    FILENAME = '/Users/ayash/Database/Database_KTP/KTP_log.ldf', 
    SIZE = 40MB, 
    MAXSIZE = 100MB, 
    FILEGROWTH = 20%)

--Use Database
USE KTP

-- membuat tabel Penduduk
CREATE TABLE Penduduk (
  ID_Penduduk VARCHAR(10) PRIMARY KEY,
  Nama_Lengkap VARCHAR(100) NOT NULL,
  Tempat_Lahir VARCHAR(50) NOT NULL,
  Tanggal_Lahir DATE NOT NULL,
  Jenis_Kelamin CHAR(1) NOT NULL CHECK (Jenis_Kelamin IN ('L', 'P')),
  Alamat TEXT NOT NULL,
  No_Telp CHAR(12) CHECK (LEN(No_Telp) <= 12)
);

-- membuat tabel Keluarga
CREATE TABLE Keluarga (
  ID_Keluarga VARCHAR(10) PRIMARY KEY,
  Kepala_Keluarga VARCHAR(10) NOT NULL,
  Alamat TEXT NOT NULL,
  FOREIGN KEY (Kepala_Keluarga) REFERENCES Penduduk(ID_Penduduk)
);

-- membuat tabel Pekerjaan
CREATE TABLE Pekerjaan (
  ID_Pekerjaan VARCHAR(10) PRIMARY KEY,
  Nama_Pekerjaan VARCHAR(50) NOT NULL,
  Deskripsi_Pekerjaan TEXT,
  ID_Penduduk VARCHAR(10),
  FOREIGN KEY (ID_Penduduk) REFERENCES Penduduk (ID_Penduduk)
);


-- membuat tabel Pendidikan
CREATE TABLE Pendidikan (
  ID_Pendidikan VARCHAR(10) PRIMARY KEY,
  Jenjang_Pendidikan VARCHAR(10) NOT NULL CHECK (Jenjang_Pendidikan IN ('TK', 'SD', 'SMP', 'SMA', 'D3', 'D4', 'S1', 'S2', 'S3', 'TS')),
  Nama_Institusi VARCHAR(100),
  Tahun_Lulus DATE,
  ID_Penduduk VARCHAR(10),
  FOREIGN KEY (ID_Penduduk) REFERENCES Penduduk (ID_Penduduk)
);

-- membuat tabel Kartu Keluarga
CREATE TABLE Kartu_Keluarga (
  ID_KK VARCHAR(10) PRIMARY KEY,
  Nomor_KK CHAR(10) NOT NULL,
  Tanggal_Dikeluarkan DATE NOT NULL
);

-- membuat tabel relasi KK_Penduduk
CREATE TABLE KK_Penduduk (
  ID_KK VARCHAR(10) NOT NULL,
  ID_Penduduk VARCHAR(10) NOT NULL,
  Status_Hubungan VARCHAR(50) NOT NULL,
  Tanggal_Lahir DATE,
  ID_Pendidikan VARCHAR(10),
  ID_Pekerjaan VARCHAR(10),
  PRIMARY KEY (ID_Penduduk, ID_KK),
  FOREIGN KEY (ID_KK) REFERENCES Kartu_Keluarga(ID_KK),
  FOREIGN KEY (ID_Penduduk) REFERENCES Penduduk(ID_Penduduk),
  FOREIGN KEY (ID_Pendidikan) REFERENCES Pendidikan(ID_Pendidikan),
  FOREIGN KEY (ID_Pekerjaan) REFERENCES Pekerjaan(ID_Pekerjaan)
);

-- membuat tabel relasi KK_Keluarga
CREATE TABLE KK_Keluarga (
  ID_KK VARCHAR(10) NOT NULL,
  ID_Keluarga VARCHAR(10) NOT NULL,
  PRIMARY KEY (ID_KK, ID_Keluarga),
  FOREIGN KEY (ID_KK) REFERENCES Kartu_Keluarga(ID_KK),
  FOREIGN KEY (ID_Keluarga) REFERENCES Keluarga(ID_Keluarga)
);


-- Membuat view
-- View untuk melihat data penduduk dan informasi kartu keluarga mereka
CREATE VIEW Data_Penduduk_KK AS
SELECT p.ID_Penduduk, p.Nama_Lengkap, p.Jenis_Kelamin, k.Nomor_KK, k.Tanggal_Dikeluarkan
FROM Penduduk p
INNER JOIN KK_Penduduk kk ON p.ID_Penduduk = kk.ID_Penduduk
INNER JOIN Kartu_Keluarga k ON kk.ID_KK = k.ID_KK;

-- View untuk melihat data keluarga beserta anggotanya
CREATE VIEW Data_Keluarga AS
SELECT kk.Nomor_KK, k.ID_Keluarga, k.Kepala_Keluarga, p.ID_Penduduk, p.Nama_Lengkap, p.Tempat_Lahir, p.Tanggal_Lahir, p.Jenis_Kelamin, p.Alamat, p.No_Telp, pj.ID_Pekerjaan, pj.Nama_Pekerjaan, pj.Deskripsi_Pekerjaan, pd.ID_Pendidikan, pd.Jenjang_Pendidikan, pd.Nama_Institusi, pd.Tahun_Lulus, kp.Status_Hubungan
FROM Kartu_Keluarga kk
INNER JOIN KK_Keluarga kkk ON kk.ID_KK = kkk.ID_KK
INNER JOIN Keluarga k ON kkk.ID_Keluarga = k.ID_Keluarga
INNER JOIN KK_Penduduk kp ON kk.ID_KK = kp.ID_KK
INNER JOIN Penduduk p ON kp.ID_Penduduk = p.ID_Penduduk
LEFT JOIN Pekerjaan pj ON kp.ID_Pekerjaan = pj.ID_Pekerjaan
LEFT JOIN Pendidikan pd ON kp.ID_Pendidikan = pd.ID_Pendidikan;

-- View untuk melihat data pekerjaan penduduk dan informasi kartu keluarga mereka
CREATE VIEW Data_Pekerjaan_KK AS
SELECT pj.ID_Pekerjaan, pj.Nama_Pekerjaan, pj.Deskripsi_Pekerjaan, p.ID_Penduduk, k.Nomor_KK, k.Tanggal_Dikeluarkan
FROM Pekerjaan pj
INNER JOIN Penduduk p ON pj.ID_Penduduk = p.ID_Penduduk
INNER JOIN KK_Penduduk kk ON p.ID_Penduduk = kk.ID_Penduduk
INNER JOIN Kartu_Keluarga k ON kk.ID_KK = k.ID_KK;

-- View untuk melihat data pendidikan penduduk dan informasi kartu keluarga mereka
CREATE VIEW Data_Pendidikan_KK AS
SELECT pd.ID_Pendidikan, pd.Jenjang_Pendidikan, pd.Nama_Institusi, pd.Tahun_Lulus, p.ID_Penduduk, k.Nomor_KK, k.Tanggal_Dikeluarkan
FROM Pendidikan pd
INNER JOIN Penduduk p ON pd.ID_Penduduk = p.ID_Penduduk
INNER JOIN KK_Penduduk kk ON p.ID_Penduduk = kk.ID_Penduduk
INNER JOIN Kartu_Keluarga k ON kk.ID_KK = k.ID_KK;

-- Select View
SELECT * FROM Data_Penduduk_KK
SELECT * FROM Data_Keluarga
SELECT * FROM Data_Pekerjaan_KK
SELECT * FROM Data_Pendidikan_KK
SELECT * FROM Penduduk

-- Mengisi tabel menggunakan data
INSERT INTO Penduduk (ID_Penduduk, Nama_Lengkap, Tempat_Lahir, Tanggal_Lahir, Jenis_Kelamin, Alamat, No_Telp)
VALUES 
('P1', 'Budi Santoso', 'Jakarta', '1980-02-01', 'L', 'Jl. Cendrawasih No. 10', '081234567890'),
('P2', 'Ani Wulandari', 'Bandung', '1981-05-12', 'P', 'Jl. Anggrek No. 5', '082345678901'),
('P3', 'Dewi Citra', 'Surabaya', '2000-12-24', 'P', 'Jl. Mawar No. 7', '083456789012');

INSERT INTO Keluarga (ID_Keluarga, Kepala_Keluarga, Alamat) VALUES
('K1', 'P1', 'Jl. Anggrek No. 10'),
('K2', 'P1', 'Jl. Anggrek No. 10'),
('K3', 'P1', 'Jl. Anggrek No. 10');

INSERT INTO Pekerjaan (ID_Pekerjaan, Nama_Pekerjaan, Deskripsi_Pekerjaan, ID_Penduduk) VALUES 
('PJ1', 'Programmer', 'Membuat aplikasi web dan mobile', 'P1'),
('PJ2', 'Marketing', 'Mempromosikan produk perusahaan', 'P2'),
('PJ3', 'Akuntan', 'Mengelola keuangan perusahaan', 'P3');

INSERT INTO Pendidikan (ID_Pendidikan, Jenjang_Pendidikan, Nama_Institusi, Tahun_Lulus, ID_Penduduk) VALUES 
('PD1', 'S1', 'Universitas A', '2020-06-01', 'P1'),
('PD2', 'D3', 'Politeknik B', '2018-06-01', 'P2'),
('PD3', 'SMA', 'SMA C', '2015-06-01', 'P3');

INSERT INTO Kartu_Keluarga (ID_KK, Nomor_KK, Tanggal_Dikeluarkan) VALUES 
('KK1', '1234567890', '2000-01-01'),
('KK2', '1234567890', '2000-01-01'),
('KK3', '1234567890', '2000-01-01');

-- memasukkan data penduduk ke dalam tabel KK_Penduduk
INSERT INTO KK_Penduduk (ID_KK, ID_Penduduk, Status_Hubungan, Tanggal_Lahir, ID_Pendidikan, ID_Pekerjaan) VALUES
('KK1', 'P1', 'Kepala Keluarga', '1980-02-01', 'PD1', 'PJ1'),
('KK2', 'P2', 'Istri', '1981-05-12', 'PD2', 'PJ2'),
('KK3', 'P3', 'Anak', '2000-12-24', 'PD3', 'PJ3');

INSERT INTO KK_Keluarga (ID_KK, ID_Keluarga)
VALUES
  ('KK1', 'K1'),
  ('KK2', 'K2'),
  ('KK3', 'K3');

-- Membuat login untuk pengguna
CREATE LOGIN pengguna1 WITH PASSWORD = 'P4ssword1';
CREATE LOGIN pengguna2 WITH PASSWORD = 'P4ssword2';

-- Membuat user untuk pengguna
CREATE USER pengguna1 FOR LOGIN pengguna1;
CREATE USER pengguna2 FOR LOGIN pengguna2

-- Membuat role untuk pengguna
CREATE ROLE pengguna1_role;
CREATE ROLE pengguna2_role;

-- Memberikan akses ke role dan login yang sesuai
ALTER ROLE pengguna1_role ADD MEMBER pengguna1;
ALTER ROLE pengguna2_role ADD MEMBER pengguna2;

-- Memberikan privilege yang berbeda pada setiap rolenya
GRANT SELECT, INSERT, UPDATE, DELETE ON Penduduk TO pengguna1_role;
GRANT SELECT ON Data_Penduduk_KK TO pengguna1_role;
GRANT SELECT, INSERT, UPDATE ON Keluarga TO pengguna1_role;
GRANT SELECT ON Pekerjaan TO pengguna1_role;
GRANT SELECT, INSERT, UPDATE ON Pendidikan TO pengguna1_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Kartu_Keluarga TO pengguna1_role;

GRANT SELECT, INSERT, UPDATE ON Penduduk TO pengguna2_role;
GRANT SELECT ON Keluarga TO pengguna2_role;
GRANT SELECT ON Pekerjaan TO pengguna2_role;
GRANT SELECT ON Pendidikan TO pengguna2_role;
GRANT SELECT, INSERT, UPDATE ON Kartu_Keluarga TO pengguna2_role;
