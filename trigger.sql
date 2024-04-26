USE askeri_sistem;
GO

-- IzinTakipTrigger adl� tetikleyiciyi kontrol eder
IF OBJECT_ID('IzinTakipTrigger') IS NOT NULL
BEGIN
    -- E�er varsa siler
    DROP TRIGGER IzinTakipTrigger
END
GO

-- IzinTakipTrigger adl� tetikleyiciyi olu�turur
CREATE TRIGGER IzinTakipTrigger
ON izin
AFTER INSERT, UPDATE
AS
BEGIN
    -- De�i�ken tan�mlar
    DECLARE @asker_id INT, @istenenIzinSure INT;

    -- Eklenen veya g�ncellenen kay�ttan bilgiler al�n�r
    SELECT @asker_id = asker_id, @istenenIzinSure = DATEDIFF(day, baslangic_tarihi, bitis_tarihi)
    FROM INSERTED;

    -- �stenen izin s�resinin 30 g�nden fazla olup olmad���n� kontrol eder
    IF @istenenIzinSure > 30
    BEGIN
        -- Hata mesaj� yazd�r�r ve i�lemi geri al�r
        PRINT 'HATA: �stenen izin s�resi 30 g�nden fazla olamaz.';
        ROLLBACK;
    END
END;
GO

-- �rnek procedure'� �a��r�r
EXEC IzinKaydi @istenenIzinSure = 11, @asker_id = 5;
GO

-- �zin ve asker bilgilerini getirir
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
