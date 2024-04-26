USE askeri_sistem;
GO
-- E�er IzinKaydi ad�nda bir stored procedure varsa, siler
IF OBJECT_ID('IzinKaydi') IS NOT NULL
BEGIN
    DROP PROCEDURE IzinKaydi;
END
GO

-- Yeni IzinKaydi stored procedure olu�turur
CREATE PROCEDURE IzinKaydi
    @istenenIzinSure INT,
    @asker_id INT
AS
BEGIN
    BEGIN TRANSACTION
	
    -- E�er bir hata olu�ursa, i�lem TRY blo�undan ��k�l�r ve CATCH blo�una gidilir
    BEGIN TRY

        -- Yeni izin talebini kontrol eder ve i�lemini yapar
        UPDATE asker
        SET @istenenIzinSure = CASE
                                    WHEN DATEDIFF(day, planlanan_izin_suresi, gerceklesen_izin_suresi) > 3 
                                        THEN @istenenIzinSure - 3
                                    ELSE @istenenIzinSure
                                END, 
            kullandigi_izin_suresi = kullandigi_izin_suresi + @istenenIzinSure + gerceklesen_izin_suresi
        FROM asker
        INNER JOIN izin ON asker.asker_id = izin.asker_id
        WHERE toplam_izin_suresi >= kullandigi_izin_suresi + @istenenIzinSure;

        -- �zin tablosuna yeni kay�t ekleme i�lemini yapar
        INSERT INTO izin (yol_suresi, bitis_tarihi, baslangic_tarihi, asker_id)
        VALUES (0, DATEADD(day, @istenenIzinSure, GETDATE()), GETDATE(), @asker_id);

        COMMIT;
    END TRY
	
    BEGIN CATCH -- Hata yakaland���nda buradaki kod �al���r
        PRINT 'HATA OLUSTU'; -- Hata mesaj�n� yazd�r�r
        ROLLBACK TRANSACTION -- E�er bir i�lem yap�ld�ysa, i�lemi geri al�r
    END CATCH
END;
GO

-- �rnek olarak procedure'� �a��r�r
EXEC IzinKaydi @istenenIzinSure = 10, @asker_id = 5;
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
