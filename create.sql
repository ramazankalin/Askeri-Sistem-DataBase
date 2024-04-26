IF DB_ID('askeri_sistem') IS NOT NULL
	BEGIN
		ALTER DATABASE [askeri_sistem] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
		USE master
		DROP DATABASE askeri_sistem	
	END
GO
CREATE DATABASE askeri_sistem

GO
USE askeri_sistem

CREATE TABLE il
(
	il_id CHAR(2) PRIMARY KEY NOT NULL,
	Ad VARCHAR(20) NOT NULL
)
GO

CREATE TABLE ilce
(
	ilce_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ilce_ad VARCHAR(20) NOT NULL,
	il_id CHAR(2) FOREIGN KEY REFERENCES il(il_id)
	ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
)
GO

CREATE TABLE operasyon
(
    operasyon_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    operasyon_ad VARCHAR(50) NOT NULL
)

CREATE TABLE rutbe
(
    rutbe_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    rutbe_ad VARCHAR(50) NOT NULL,
    maas MONEY NOT NULL
)

CREATE TABLE techizat_tur
(
    techizat_tur_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    techizat_tur_ad VARCHAR(40) NOT NULL
)

CREATE TABLE techizat
(
    techizat_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    techizat_ad VARCHAR(50) NOT NULL,
    seri_no VARCHAR(50) NOT NULL,
    ozellikler VARCHAR(100),
    durum SMALLINT NOT NULL,
	techizat_tur_id INT FOREIGN KEY 
	REFERENCES techizat_tur(techizat_tur_id) NOT NULL
)

CREATE TABLE nobet_yeri
(
    nobet_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    nobet_ad VARCHAR(50) NOT NULL,
    silah_durumu BIT DEFAULT 0 NOT NULL
)

CREATE TABLE sinif
(
    sinif_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    sinif_ad VARCHAR(50) NOT NULL
)

CREATE TABLE asker
(
	asker_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ad VARCHAR(50) NOT NULL,
	soyad VARCHAR(50) NOT NULL,
	tc_no CHAR(11) UNIQUE NOT NULL,
	adres VARCHAR(100) NOT NULL,
	cinsiyet BIT NOT NULL,
	atis_durumu BIT DEFAULT 0 NOT NULL,
	dogum_tarihi DATE NOT NULL,
	email VARCHAR(30),
	telefon_no CHAR(11),
	giris_tarihi DATE NOT NULL,
	kullandigi_izin_suresi INT DEFAULT 0 NOT NULL,
	askerlik_suresi INT,
	toplam_izin_suresi INT NOT NULL,
	kalan_izin_suresi AS DATEDIFF(day,kullandigi_izin_suresi,toplam_izin_suresi),
	terhis_tarihi AS DATEADD(day,askerlik_suresi,giris_tarihi),
	rutbe_id INT FOREIGN KEY REFERENCES rutbe(rutbe_id) NOT NULL,
	ilce_id INT FOREIGN KEY REFERENCES ilce(ilce_id) NOT NULL
)

CREATE TABLE izin
(
    izin_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    yol_suresi INT NOT NULL DEFAULT 0,
    bitis_tarihi DATE,
    baslangic_tarihi DATE,
	planlanan_izin_suresi AS DATEDIFF(day,baslangic_tarihi,bitis_tarihi),
	gerceklesen_izin_suresi AS DATEDIFF(day,baslangic_tarihi, GETDATE()),
	asker_id INT FOREIGN KEY REFERENCES asker(asker_id) NOT NULL
)

CREATE TABLE birim
(
	birim_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	adres VARCHAR(100) NOT NULL,
	telefon_no CHAR(11) NOT NULL,
	birim_adi VARCHAR(50) NOT NULL,
	ust_birlik INT FOREIGN KEY REFERENCES birim(birim_id) NULL,
	nobet_id INT FOREIGN KEY REFERENCES nobet_yeri(nobet_id) NOT NULL,
	ilce_id INT FOREIGN KEY REFERENCES ilce(ilce_id) NOT NULL
)

CREATE TABLE asker_nobeti
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	asker_id INT FOREIGN KEY REFERENCES asker(asker_id) NOT NULL,
	nobet_id INT FOREIGN KEY REFERENCES nobet_yeri(nobet_id) NOT NULL,
	baslangic_tarihi_saati DATETIME NOT NULL,
	bitis_tarihi_saati DATETIME NOT NULL
)

CREATE TABLE askeri_birim
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	asker_id INT FOREIGN KEY REFERENCES asker(asker_id) NOT NULL,
	birim_id INT FOREIGN KEY REFERENCES birim(birim_id) NOT NULL,
	baslangic_tarihi DATE NOT NULL,
	bitis_tarihi DATE
)

CREATE TABLE birim_sinifi
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	birim_id INT FOREIGN KEY REFERENCES birim(birim_id) NOT NULL,
	sinif_id INT FOREIGN KEY REFERENCES sinif(sinif_id) NOT NULL,
	CONSTRAINT ubirim_sinifi UNIQUE(birim_id,sinif_id)
)

CREATE TABLE birim_techizati
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	birim_id INT FOREIGN KEY REFERENCES birim(birim_id) NOT NULL,
	techizat_id INT FOREIGN KEY REFERENCES techizat(techizat_id) NOT NULL,
	baslangic_tarihi DATE DEFAULT GETDATE() NOT NULL,
	bitis_tarihi DATE
)

CREATE TABLE asker_techizati
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	asker_id INT FOREIGN KEY REFERENCES asker(asker_id) NOT NULL,
	techizat_id INT FOREIGN KEY REFERENCES techizat(techizat_id) NOT NULL,
	baslangic_tarihi DATE DEFAULT GETDATE() NOT NULL,
	bitis_tarihi DATE
)

CREATE TABLE operasyon_birimi
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	birim_id INT FOREIGN KEY REFERENCES birim(birim_id) NOT NULL,
	operasyon_id INT FOREIGN KEY REFERENCES operasyon(operasyon_id) NOT NULL,
	baslangic_tarihi DATE DEFAULT GETDATE() NOT NULL,
	bitis_tarihi DATE
)

CREATE TABLE operasyon_yeri
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	operasyon_id INT FOREIGN KEY REFERENCES operasyon(operasyon_id) NOT NULL,
	ilce_id INT FOREIGN KEY REFERENCES ilce(ilce_id) NOT NULL,
	CONSTRAINT uoperasyon_yeri UNIQUE(operasyon_id,ilce_id)
)

INSERT INTO il (il_id, Ad) VALUES ('34', 'Ýstanbul');
INSERT INTO il (il_id, Ad) VALUES ('36', 'Kars');
INSERT INTO il (il_id, Ad) VALUES ('55', 'Samsun');
INSERT INTO il (il_id, Ad) VALUES ('60', 'Tokat');
INSERT INTO il (il_id, Ad) VALUES ('77', 'Yalova');

INSERT INTO ilce (ilce_ad, il_id) VALUES ('Gaziosmanpaþa', '34');
INSERT INTO ilce (ilce_ad, il_id) VALUES ('Sarýkamýþ', '36');
INSERT INTO ilce (ilce_ad, il_id) VALUES ('Çarþamba', '55');
INSERT INTO ilce (ilce_ad, il_id) VALUES ('Merkez', '60');
INSERT INTO ilce (ilce_ad, il_id) VALUES ('Çýnarcýk', '77');

INSERT INTO operasyon (operasyon_ad) 
VALUES ('Pençe-Kilit Operasyonu');

INSERT INTO rutbe (rutbe_ad, maas) VALUES ('Onbaþý', 40000);
INSERT INTO rutbe (rutbe_ad, maas) VALUES ('Yüzbaþý', 45000);
INSERT INTO rutbe (rutbe_ad, maas) VALUES ('Binbaþý', 50000);
INSERT INTO rutbe (rutbe_ad, maas) VALUES ('Albay', 55000);
INSERT INTO rutbe (rutbe_ad, maas) VALUES ('Orgeneral', 80000);

INSERT INTO techizat_tur (techizat_tur_ad) VALUES ('Silah');

INSERT INTO techizat (techizat_ad, seri_no, ozellikler, durum, techizat_tur_id) VALUES ('AK-47', '12345', 'Otamatik tüfek', 1, 1);

INSERT INTO nobet_yeri (nobet_ad, silah_durumu) VALUES ('Balýklý mh', 1);
INSERT INTO nobet_yeri (nobet_ad, silah_durumu) VALUES ('Merkez mh', 1);
INSERT INTO nobet_yeri (nobet_ad, silah_durumu) VALUES ('Emek mh', 1);
INSERT INTO nobet_yeri (nobet_ad, silah_durumu) VALUES ('Mimarsinan mh', 1);
INSERT INTO nobet_yeri (nobet_ad, silah_durumu) VALUES ('Barbaros mh', 1);

INSERT INTO asker (ad, soyad, tc_no, adres, cinsiyet, atis_durumu, dogum_tarihi, email, telefon_no, giris_tarihi, kullandigi_izin_suresi, askerlik_suresi, toplam_izin_suresi, rutbe_id, ilce_id)
VALUES ('Harun', 'Kurnaz', '11111111111', 'Mimarsinan mh', 1, 1, '2002-04-03', 'harunkurnaz@gmail.com', '05050505050', '2023-04-03', 0, 180, 30, 1, 3);
INSERT INTO asker (ad, soyad, tc_no, adres, cinsiyet, atis_durumu, dogum_tarihi, email, telefon_no, giris_tarihi, kullandigi_izin_suresi, askerlik_suresi, toplam_izin_suresi, rutbe_id, ilce_id)
VALUES ('Ramazan', 'Kalin', '22222222222', 'Barbaros mh', 1, 1, '2002-11-22', 'ramazankalin@gmail.com', '05300300303', '2023-11-22', 10, 180, 30, 5, 1);
INSERT INTO asker (ad, soyad, tc_no, adres, cinsiyet, atis_durumu, dogum_tarihi, email, telefon_no, giris_tarihi, kullandigi_izin_suresi, askerlik_suresi, toplam_izin_suresi, rutbe_id, ilce_id)
VALUES ('Yavuz', 'Duman', '33333333333', 'Merkez mh', 1, 1, '2001-12-24', 'yavuzduman@gmail.com', '05414414141', '2023-12-24', 5, 180, 30, 2, 4);
INSERT INTO asker (ad, soyad, tc_no, adres, cinsiyet, atis_durumu, dogum_tarihi, email, telefon_no, giris_tarihi, kullandigi_izin_suresi, askerlik_suresi, toplam_izin_suresi, rutbe_id, ilce_id)
VALUES ('Özgenur', 'Bilican', '44444444444', 'Emek mh', 0, 1, '2001-05-19', 'ozgenurbilican@gmail.com', '05515515151', '2023-05-19', 16, 180, 30, 3, 2);
INSERT INTO asker (ad, soyad, tc_no, adres, cinsiyet, atis_durumu, dogum_tarihi, email, telefon_no, giris_tarihi, kullandigi_izin_suresi, askerlik_suresi, toplam_izin_suresi, rutbe_id, ilce_id)
VALUES ('Furkan', 'Uzun', '55555555555', 'Balýklý mh', 1, 1, '2001-03-16', 'furkanuzun@gmail.com', '05300300331', '2023-12-01', 0, 180, 30, 1, 5);

INSERT INTO izin (asker_id,baslangic_tarihi,bitis_tarihi,yol_suresi)
VALUES (5,'2023-12-15','2023-12-20', 2);

INSERT INTO birim (adres, telefon_no, birim_adi, ust_birlik, nobet_id, ilce_id)
VALUES ('Balýklý mh', '1111111111', 'Tim', NULL , 1, 5);
INSERT INTO birim (adres, telefon_no, birim_adi, ust_birlik, nobet_id, ilce_id)
VALUES ('Merkez mh', '2222222222', 'Bölük', NULL, 2, 4);
INSERT INTO birim (adres, telefon_no, birim_adi, ust_birlik, nobet_id, ilce_id)
VALUES ('Emek mh', '3333333333', 'Tabur', NULL, 3, 2);
INSERT INTO birim (adres, telefon_no, birim_adi, ust_birlik, nobet_id, ilce_id)
VALUES ('Mimarsinan mh', '4444444444', 'Alay', NULL, 4, 3);
INSERT INTO birim (adres, telefon_no, birim_adi, ust_birlik, nobet_id, ilce_id)
VALUES ('Barbaros mh', '5555555555', 'Ordu', NULL, 5, 1);


INSERT INTO askeri_birim (asker_id, birim_id, baslangic_tarihi, bitis_tarihi)
VALUES (1, 4, '2023-01-01', '2025-11-22');
INSERT INTO askeri_birim (asker_id, birim_id, baslangic_tarihi, bitis_tarihi)
VALUES (4, 3, '2023-01-01', '2025-11-22');

INSERT INTO asker_techizati(asker_id,baslangic_tarihi,bitis_tarihi,techizat_id)
VALUES(1,'2003-04-03',NULL,1);

INSERT INTO operasyon_birimi (birim_id, operasyon_id, baslangic_tarihi, bitis_tarihi)
VALUES (4, 1, '2023-01-01', '2025-11-22');
INSERT INTO operasyon_birimi (birim_id, operasyon_id, baslangic_tarihi, bitis_tarihi)
VALUES (3, 1, '2023-01-01', '2025-11-22');

INSERT INTO operasyon_yeri (operasyon_id, ilce_id)
VALUES (1, 3);
