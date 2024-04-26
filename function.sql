USE askeri_sistem;
GO
--Fonksiyonun veri tabanında var olup olmadığını kontrol eder.
IF OBJECT_ID('dbo.KalanAskerlikSuresi') IS NOT NULL
BEGIN
	--Eğer varsa siler.
    DROP FUNCTION dbo.KalanAskerlikSuresi
END
GO

-- Yeni bir fonksiyon oluşturur
CREATE FUNCTION dbo.KalanAskerlikSuresi(@askerID INT)
RETURNS INT
AS
BEGIN
    DECLARE @kalanAskerlikSuresi INT;

    -- Askerin kalan askerlik süresini hesaplar
    SELECT @kalanAskerlikSuresi = 
        CASE
            WHEN GETDATE() < terhis_tarihi THEN 
                DATEDIFF(day, GETDATE(), terhis_tarihi) - kalan_izin_suresi
            ELSE 0
        END
    FROM asker
    WHERE asker_id = @askerID;

    -- Hesaplanan değeri döndürür
    RETURN @kalanAskerlikSuresi;
END;
GO

-- Test için bir asker ID'si alır
DECLARE @testAskerID INT = 2;

-- Sonucu görüntüler
SELECT ad, soyad, dbo.KalanAskerlikSuresi(@testAskerID) as KalanAskerlikSuresi
FROM asker
WHERE asker_id = @testAskerID;
