﻿-- Login so sánh usesrname và pass
create procedure sp_LoginAccount
	@UserName varchar(50),
	@UserPass varchar(50)
as
BEGIN
	if exists (select AccountID from TAIKHOAN where UserName = @UserName and PWDCOMPARE(@UserPass, Password) = 1)
		begin
			select AccountID
			from TAIKHOAN
			where UserName = @UserName and PWDCOMPARE(@UserPass, Password) = 1 
		end
	else
		begin
			Select 0 as AccountID
		end
END

go



-- Phân loại user theo admin hoặc giáo viên hoặc sinh viên
create procedure sp_AuthUser
@AccountID int
as 
BEGIN
	if EXISTS ( select * from GIAOVIEN where AccountID = @AccountID)
		begin 
			select GV.AccountID, GV.Name, TK.Email from GIAOVIEN GV
			inner join TAIKHOAN TK on TK.AccountID = GV.AccountID
			where GV.AccountID = @AccountID
		end
	else 
		begin 
			select SV.AccountID, SV.Name, TK.Email from SINHVIEN SV
			inner join TAIKHOAN TK on TK.AccountID = SV.AccountID
			where SV.AccountID = @AccountID
		end
END

--exec sp_AuthUser 5


go

--Hiển thị tất cả chủ đề
create procedure sp_ShowAllTopic
as
select * from CHUDE

go

-- Hiển thị tất cả từ vựng
create procedure sp_SelectAllTuVung
as
select * from TUVUNG

go

--Hiển thị từ vựng theo chủ đề
create procedure sp_SelectTuVungByTopicID
@TopicID int
as
select * 
from TUVUNG
where TopicID = @TopicID

--exec sp_SelectTuVungByTopicID 3

go

--Hiển thị chủ đề theo khoa
create procedure sp_ShowTopicByFaculty
@IDFACULTY int
as
BEGIN
	select CD.TopicID, CD.TopicName, CD.CreatedBy, CD.QuantityWords
	from CHUDE CD
	where CD.IDFACULTY = @IDFACULTY
END

go

-- Lọc ra khoa của User(GV,SV) lưu vào biến @IDFaculty, sau đó chạy thủ tục sau để lấy ra topic của khoa đó
alter procedure sp_userFalculty
@AccountID int
as
BEGIN
	DECLARE @IDFaculty INT


	IF EXISTS (
		select *
		from SINHVIEN SV
		inner join LOP L on L.IDCLASS = SV.IDCLASS
		where SV.AccountID = @AccountID )

		begin
			select @IDFaculty = L.IDFACULTY
			from SINHVIEN SV
			inner join LOP L on L.IDCLASS = SV.IDCLASS
			where SV.AccountID = @AccountID

			exec sp_ShowTopicByFaculty @IDFaculty
		end

	ELSE 
		begin
			select @IDFaculty = L.IDFACULTY
			from GIAOVIEN GV
			inner join LOP L on L.MaGV = GV.MaGV
			where GV.AccountID = @AccountID;

			exec sp_ShowTopicByFaculty @IDFaculty
		end	
END

--exec sp_userFalculty 1
--exec sp_ShowTopicByFaculty 1


go


--Tạo mã OTP
create PROCEDURE sp_GenerateOTP
    @AccountID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Tạo mã OTP ngẫu nhiên
    DECLARE @OTP CHAR(6) = CONVERT(CHAR(6), ABS(CHECKSUM(NEWID())) % 900000 + 100000);

    -- Thêm OTP vào bảng
    INSERT INTO OTP (AccountID, OTPCode, ExpiredAt) 
    VALUES (@AccountID, @OTP, DATEADD(MINUTE, 1, GETDATE()));

    -- Xóa các mã OTP đã hết hạn
    DELETE FROM OTP WHERE ExpiredAt < GETDATE();
    
    -- Lấy thông tin OTP vừa được thêm vào bảng
    SELECT ID, AccountID, OTPCode, CreatedAt, ExpiredAt 
    FROM OTP 
    WHERE ID = SCOPE_IDENTITY();
END

--exec generateOTP 1

go

-- kiểm tra email có tồn tại trong tài khoản ( 0 = không tồn tại, != 0 tồn tại) 
alter procedure sp_CheckEmailValid
@Email varchar(100)
as
BEGIN
	if EXISTS (SELECT * from TAIKHOAN where Email = @Email )
		begin
			select AccountID 
			from TAIKHOAN where Email = @Email
		end
	else
		begin
			select 0 as AccountID 
		end
END

--exec sp_CheckEmailValid "buihuuloc2001@gmail.com"

----------------- TESTING AREA













