USE askeri_sistem;
GO
-- Eðer IzinKaydi adýnda bir stored procedure varsa, siler
IF OBJECT_ID('IzinKaydi') IS NOT NULL
BEGIN
    DROP PROCEDURE IzinKaydi;
END
GO

-- Yeni IzinKaydi stored procedure oluþturur
CREATE PROCEDURE IzinKaydi
    @istenenIzinSure INT,
    @asker_id INT
AS
BEGIN
    BEGIN TRANSACTION
	
    -- Eðer bir hata oluþursa, iþlem TRY bloðundan çýkýlýr ve CATCH bloðuna gidilir
    BEGIN TRY

        -- Yeni izin talebini kontrol eder ve iþlemini yapar
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

        -- Ýzin tablosuna yeni kayýt ekleme iþlemini yapar
        INSERT INTO izin (yol_suresi, bitis_tarihi, baslangic_tarihi, asker_id)
        VALUES (0, DATEADD(day, @istenenIzinSure, GETDATE()), GETDATE(), @asker_id);

        COMMIT;
    END TRY
	
    BEGIN CATCH -- Hata yakalandýðýnda buradaki kod çalýþýr
        PRINT 'HATA OLUSTU'; -- Hata mesajýný yazdýrýr
        ROLLBACK TRANSACTION -- Eðer bir iþlem yapýldýysa, iþlemi geri alýr
    END CATCH
END;
GO

-- Örnek olarak procedure'ý çaðýrýr
EXEC IzinKaydi @istenenIzinSure = 10, @asker_id = 5;
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
