USE askeri_sistem;
GO

-- IzinTakipTrigger adlý tetikleyiciyi kontrol eder
IF OBJECT_ID('IzinTakipTrigger') IS NOT NULL
BEGIN
    -- Eðer varsa siler
    DROP TRIGGER IzinTakipTrigger
END
GO

-- IzinTakipTrigger adlý tetikleyiciyi oluþturur
CREATE TRIGGER IzinTakipTrigger
ON izin
AFTER INSERT, UPDATE
AS
BEGIN
    -- Deðiþken tanýmlar
    DECLARE @asker_id INT, @istenenIzinSure INT;

    -- Eklenen veya güncellenen kayýttan bilgiler alýnýr
    SELECT @asker_id = asker_id, @istenenIzinSure = DATEDIFF(day, baslangic_tarihi, bitis_tarihi)
    FROM INSERTED;

    -- Ýstenen izin süresinin 30 günden fazla olup olmadýðýný kontrol eder
    IF @istenenIzinSure > 30
    BEGIN
        -- Hata mesajý yazdýrýr ve iþlemi geri alýr
        PRINT 'HATA: Ýstenen izin süresi 30 günden fazla olamaz.';
        ROLLBACK;
    END
END;
GO

-- Örnek procedure'ý çaðýrýr
EXEC IzinKaydi @istenenIzinSure = 11, @asker_id = 5;
GO

-- Ýzin ve asker bilgilerini getirir
SELECT
    asker.ad,
    asker.soyad,
    asker.kullandigi_izin_suresi,
    asker.toplam_izin_suresi,
    asker.kalan_izin_suresi,
    izin.baslangic_tarihi,
    izin.bitis_tarihi,
    izin.planlanan_izin_suresi,
    izin.gerceklesen_izin_suresi    
FROM
    asker
INNER JOIN izin ON asker.asker_id = izin.asker_id;
