USE askeri_sistem
GO

-- Eðer vAskerKalanSureIlceyeGore adýnda bir view varsa, siler
IF OBJECT_ID('vAskerKalanSureIlceyeGore') IS NOT NULL
BEGIN
    DROP VIEW vAskerKalanSureIlceyeGore;
END
GO

-- Yeni bir view oluþturur
CREATE VIEW vAskerKalanSureIlceyeGore AS
SELECT
    a.asker_id,
    a.ad,
    a.soyad,
    a.giris_tarihi,
    a.terhis_tarihi,
    a.toplam_izin_suresi,
    a.kullandigi_izin_suresi,
    a.kalan_izin_suresi,
    CASE
		--Askerlik durumunu(bitip-bitmediðini) kontrol eder.
        WHEN dbo.KalanAskerlikSuresi(a.asker_id) > 0 THEN 'Aktif'
        ELSE 'Terhis Oldu'
    END AS askerlik_durumu,
    dbo.KalanAskerlikSuresi(a.asker_id) AS KalanAskerlikSuresi,
    i.ilce_ad
FROM
    asker a
LEFT JOIN ilce i ON a.ilce_id = i.ilce_id;
GO

-- Ýlgili ilçede bulunan askerleri getirir
SELECT
    v.asker_id,
    v.ad,
    v.soyad,
    v.giris_tarihi,
    v.terhis_tarihi,
    v.toplam_izin_suresi,
    v.kullandigi_izin_suresi,
    v.kalan_izin_suresi,
    v.askerlik_durumu,
    v.KalanAskerlikSuresi,
    v.ilce_ad
FROM
    vAskerKalanSureIlceyeGore v
INNER JOIN asker a ON v.asker_id = a.asker_id
WHERE ilce_ad = 'Çarþamba';
