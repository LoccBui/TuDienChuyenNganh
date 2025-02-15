﻿--drop database HocTiengAnh
use master

go

create database HocTiengAnh

go

use HocTiengAnh

go

create table NHOMTK (
	RoleID tinyint IDENTITY(1,1),
	Priority tinyint,
	RoleName nvarchar(10),

	PRIMARY KEY(RoleID)
)
go

create table TAIKHOAN (
	AccountID int IDENTITY(1,1),
	Username varchar(50) UNIQUE,
	Name nvarchar(100),
	Password varbinary(100),
	Email varchar(100) UNIQUE,
	Image varchar(200) default 'default',
	Active bit,
	RoleID tinyint,

	PRIMARY KEY (AccountID),
	FOREIGN KEY (RoleID) REFERENCES NHOMTK(RoleID),
)
go

create table KHOA(
	IDFACULTY tinyint IDENTITY(1,1),
	FacultyName nvarchar(100),

	PRIMARY KEY (IDFACULTY),
)

go 

create table GIAOVIEN (
	MaGV smallint,
	IDFACULTY tinyint,
	AccountID int,
	Gender nvarchar(10),
	DateCreated datetime,

	PRIMARY KEY (MaGV),
	FOREIGN KEY (AccountID) REFERENCES TAIKHOAN(AccountID),
	FOREIGN KEY (IDFACULTY) REFERENCES KHOA(IDFACULTY),
)

go


create table LOP(
	IDCLASS smallint IDENTITY(1,1) UNIQUE,
	ClassName varchar(50),
	IDFACULTY tinyint,

	PRIMARY KEY (IDCLASS),
	FOREIGN KEY (IDFACULTY) REFERENCES KHOA(IDFACULTY)
)

go

create table SINHVIEN (
	MaSV int,
	AccountID int,
	Gender nvarchar(10),
	DateCreated datetime,

	IDCLASS smallint,

	PRIMARY KEY (MaSV),
	FOREIGN KEY (IDCLASS) REFERENCES LOP(IDCLASS),
	FOREIGN KEY (AccountID) REFERENCES TAIKHOAN(AccountID),

)
go



create table CHUDE (
	TopicID int IDENTITY(1,1),
	IDFACULTY tinyint,
	TopicName nvarchar(100),
	TopicDescribe nvarchar(200),
	QuantityWords smallint,
	Active bit,
	CreatedBy nvarchar(100),

	PRIMARY KEY (TopicID),
	FOREIGN KEY (IDFACULTY) REFERENCES KHOA(IDFACULTY)
)


create table TUVUNG(
	VocabID int IDENTITY(1,1),
	TopicID int,

	Frequency int,
	Word varchar(50),
	IPA nvarchar(100),
	Label varchar(50),
	Lemma varchar(200),
	Vietnamese nvarchar(200),
	Cluster varchar(100),
	Position varchar(100),
	Example varchar(400),
	VN_Example nvarchar(400),
	Resources varchar(400),

	Active bit,
	Learned bit, 
	Level tinyint,

	PRIMARY KEY (VocabID),
	FOREIGN KEY (TopicID) REFERENCES CHUDE(TopicID)
)
GO

CREATE TABLE CHITIETHOC (
  DetailID int IDENTITY(1,1),
  AccountID int,
  VocabID int,
  TopicID int,
  Learned bit,
  Level tinyint,
  WrongTimes smallint,
  Score int,
  PRIMARY KEY (DetailID),
  FOREIGN KEY (AccountID) REFERENCES TAIKHOAN(AccountID),
  FOREIGN KEY (VocabID) REFERENCES TUVUNG(VocabID),
  FOREIGN KEY (TopicID) REFERENCES CHUDE(TopicID)
)


GO


create table TUVUNGCANHAN(
	PersonalVocabID int IDENTITY(1,1),
	PersonalVocabName nvarchar(200),
	AccountID int, 
	IsDefault bit default 0,

	PRIMARY KEY (PersonalVocabID),
	FOREIGN KEY (AccountID) REFERENCES TAIKHOAN(AccountID)
)
go

create TABLE CHITIETTUCANHAN (
    PersonalDetailID int IDENTITY(1,1),
    PersonalVocabID int,
    VocabID int,
    AccountID int,
    PRIMARY KEY (PersonalDetailID),
    FOREIGN KEY (PersonalVocabID) REFERENCES TUVUNGCANHAN(PersonalVocabID),
    FOREIGN KEY (VocabID) REFERENCES TUVUNG(VocabID),
    FOREIGN KEY (AccountID) REFERENCES TAIKHOAN(AccountID)
);


go 

create table CAUAPDUNG (
	EXID int IDENTITY(1,1),
	Example varchar(400),
	VocabID int,

	PRIMARY KEY (EXID),
	FOREIGN KEY (VocabID) REFERENCES TUVUNG(VocabID)
)

go 



create table OTP(
	ID int IDENTITY(1,1),
	AccountID int NOT NULL,
	OTPCODE char(6) NOT NULL,
	CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
	ExpiredAt DATETIME NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY (AccountID) REFERENCES TAIKHOAN(AccountID),
)

go



--INSERT DATA
GO

SET IDENTITY_INSERT [dbo].[NHOMTK] ON 
INSERT [dbo].[NHOMTK] ([RoleID], [Priority], [RoleName]) VALUES (1, 100, N'Admin')
INSERT [dbo].[NHOMTK] ([RoleID], [Priority], [RoleName]) VALUES (2, 10, N'Giáo viên')
INSERT [dbo].[NHOMTK] ([RoleID], [Priority], [RoleName]) VALUES (3, 1, N'Sinh viên')
SET IDENTITY_INSERT [dbo].[NHOMTK] OFF

GO

SET IDENTITY_INSERT [dbo].[TAIKHOAN] ON 
INSERT [dbo].[TAIKHOAN] ([AccountID], [Username],[Name], [Password], [Email], [Active], [RoleID]) VALUES (1, N'loc', N'Bùi Hữu Lộc',0x0200BB89D3BAD30E63E2A7C472E354099014FCC23E5E56FB091375B6D6D972DCE82DD572C0C975A5E620ACE39093B0E8F885DBB43022B4D877E4A14EB08D708CE4593020F435, 'buihuuloc2001@gmail.com',  1, 3)
INSERT [dbo].[TAIKHOAN] ([AccountID], [Username],[Name], [Password], [Email], [Active], [RoleID]) VALUES (2, N'admin',N'Nguyễn Minh Phúc',0x0200BB89D3BAD30E63E2A7C472E354099014FCC23E5E56FB091375B6D6D972DCE82DD572C0C975A5E620ACE39093B0E8F885DBB43022B4D877E4A14EB08D708CE4593020F435 , 'phuc@gmail.com', 1, 1)
INSERT [dbo].[TAIKHOAN] ([AccountID], [Username],[Name], [Password], [Email], [Active], [RoleID]) VALUES (3, N'an', N'Nguyễn Lê An',0x0200BB89D3BAD30E63E2A7C472E354099014FCC23E5E56FB091375B6D6D972DCE82DD572C0C975A5E620ACE39093B0E8F885DBB43022B4D877E4A14EB08D708CE4593020F435 , 'an@gmail.com',1, 3)
INSERT [dbo].[TAIKHOAN] ([AccountID], [Username],[Name], [Password], [Email], [Active], [RoleID]) VALUES (4, N'huuhiep',N'Trần Hữu Hiệp',0x0200BB89D3BAD30E63E2A7C472E354099014FCC23E5E56FB091375B6D6D972DCE82DD572C0C975A5E620ACE39093B0E8F885DBB43022B4D877E4A14EB08D708CE4593020F435 , 'tranhuuhiep@gmail.com',1, 2)
INSERT [dbo].[TAIKHOAN] ([AccountID], [Username],[Name], [Password], [Email], [Active], [RoleID]) VALUES (5, N'tranbin',N'Ka Bin',0x0200BB89D3BAD30E63E2A7C472E354099014FCC23E5E56FB091375B6D6D972DCE82DD572C0C975A5E620ACE39093B0E8F885DBB43022B4D877E4A14EB08D708CE4593020F435 , 'tranbin@gmail.com',1, 2)
INSERT [dbo].[TAIKHOAN] ([AccountID], [Username],[Name], [Password], [Email], [Active], [RoleID]) VALUES (6, N'user test',N'User test',0x0200BB89D3BAD30E63E2A7C472E354099014FCC23E5E56FB091375B6D6D972DCE82DD572C0C975A5E620ACE39093B0E8F885DBB43022B4D877E4A14EB08D708CE4593020F435 , 'test1@gmail.com',1, 3)
SET IDENTITY_INSERT [dbo].[TAIKHOAN] OFF

GO


SET IDENTITY_INSERT [dbo].[KHOA] ON 
INSERT [dbo].[KHOA] ([IDFACULTY], [FacultyName]) VALUES (1, N'Công nghệ thông tin')
INSERT [dbo].[KHOA] ([IDFACULTY], [FacultyName]) VALUES (2, N'Dược')
INSERT [dbo].[KHOA] ([IDFACULTY], [FacultyName]) VALUES (3, N'Maketing')
SET IDENTITY_INSERT [dbo].[KHOA] OFF

GO

INSERT [dbo].[GIAOVIEN] ([MaGV], [IDFACULTY], [AccountID], [Gender], [DateCreated]) VALUES (1, 1, 2, N'Nam', CAST(N'2023-02-20T00:00:00.000' AS DateTime))
INSERT [dbo].[GIAOVIEN] ([MaGV], [IDFACULTY], [AccountID], [Gender], [DateCreated]) VALUES (2, 2, 4, N'Nam', CAST(N'2023-02-20T00:00:00.000' AS DateTime))
INSERT [dbo].[GIAOVIEN] ([MaGV], [IDFACULTY], [AccountID], [Gender], [DateCreated]) VALUES (3, 3, 5, N'Nam', CAST(N'2023-02-20T00:00:00.000' AS DateTime))

GO

SET IDENTITY_INSERT [dbo].[LOP] ON 
INSERT [dbo].[LOP] ([IDCLASS], [ClassName], [IDFACULTY]) VALUES (1, N'19CT114', 1)
INSERT [dbo].[LOP] ([IDCLASS], [ClassName], [IDFACULTY]) VALUES (2, N'19DC001', 2)
INSERT [dbo].[LOP] ([IDCLASS], [ClassName], [IDFACULTY]) VALUES (3, N'19MK112', 3)
SET IDENTITY_INSERT [dbo].[LOP] OFF

GO

INSERT [dbo].[SINHVIEN] ([MaSV],[AccountID], [Gender], [DateCreated], [IDCLASS]) VALUES (1, 1, N'Nam', CAST(N'2023-02-21T00:00:00.000' AS DateTime), 1)
INSERT [dbo].[SINHVIEN] ([MaSV],[AccountID], [Gender], [DateCreated], [IDCLASS]) VALUES (2, 3, N'Nam', CAST(N'2023-02-20T00:00:00.000' AS DateTime), 1)
INSERT [dbo].[SINHVIEN] ([MaSV],[AccountID], [Gender], [DateCreated], [IDCLASS]) VALUES (3, 6, N'Nam', CAST(N'2023-02-20T00:00:00.000' AS DateTime), 2)

GO

SET IDENTITY_INSERT [dbo].[CHUDE] ON 
INSERT [dbo].[CHUDE] ([TopicID],[IDFACULTY], [TopicName], [TopicDescribe], [QuantityWords], [Active], [CreatedBy] ) VALUES (1, 1, N'Chuyên Ngành CNTT', N'Ví dụ 1', 10, 1, N'Minh Phúc')
INSERT [dbo].[CHUDE] ([TopicID],[IDFACULTY], [TopicName], [TopicDescribe], [QuantityWords], [Active], [CreatedBy] ) VALUES (2, 2, N'Chuyên Ngành DƯỢC', N'Ví dụ 1', 10, 1, N'Hữu Hiệp')
INSERT [dbo].[CHUDE] ([TopicID],[IDFACULTY], [TopicName], [TopicDescribe], [QuantityWords], [Active], [CreatedBy] ) VALUES (3, 3, N'Chuyên Ngành MARKETING', N'Ví dụ 2', 20, 1, N'Trần Bin')
SET IDENTITY_INSERT [dbo].[CHUDE] OFF

GO

SET IDENTITY_INSERT [dbo].[TUVUNG] ON 
INSERT [dbo].[TUVUNG] ([VocabID], [TopicID], [Frequency], [Word], [IPA], [Label], [Lemma], [Vietnamese], [Cluster], [Position], [Example], [VN_Example], [Resources], [Active], [Learned], [Level]) VALUES (1, 1, 1, 'benefit', 'N/ˈbenɪfɪt/', 'noun', 'benefits', N'lợi ích', 'benefit from', 'on left', 'Although at a group level most benefit from ICS is obtained at a low dose, individual ICS responsiveness varies', N'Mặc dù lợi ích từ ICS liều thấp đều được ghi nhận ở cấp độ nhóm nhưng sự đáp ứng với ICS của mỗi cá nhân thì lại khác nhau.', 'GINA 2020. (attach file txt) ', 1, 1, 1)
INSERT [dbo].[TUVUNG] ([VocabID], [TopicID], [Frequency], [Word], [IPA], [Label], [Lemma], [Vietnamese], [Cluster], [Position], [Example], [VN_Example], [Resources], [Active], [Learned], [Level]) VALUES (2, 1, 1, 'benefit', 'N/ˈbenɪfɪt/', 'Verb', N'benefits/benefiting/benefited', N'hưởng lợi (từ), có được lợi ích', N'benefit from', N'on left', 'this is example', N'Một số bệnh nhân không kiểm soát được bệnh hen suyễn khi sử dụng ICS-LABA liều thấp (dù đã tuân thủ tốt và sử dụng bình hít đúng kỹ thuật) thì có thể được hưởng lợi từ việc tăng liều duy trì lên mức trung bình.', 'GINA 2020. (attach file txt) ', 1, 1, 1)
INSERT [dbo].[TUVUNG] ([VocabID], [TopicID], [Frequency], [Word], [IPA], [Label], [Lemma], [Vietnamese], [Cluster], [Position], [Example], [VN_Example], [Resources], [Active], [Learned], [Level]) VALUES (3, 1, 1, 'include', 'N/ɪnˈkluːd /', 'verb', N'includeing/included/includes', N'Bao gồm, bao hàm, gồm có, chứa trong', N'included in', N'on left', N'Some (e.g. diphenhydramine) may also be included in cold remedies for their supposed antitussive action.', N'Một số thuốc (ví như như: diphenhylamine) cũng có thể bao gồm trong các biện pháp điều trị cảm lạnh với tác dụng trị ho của các thuốc này.', 'Symptoms in the Pharmacy_ A Guide to the Management of Common Illnesses-Wiley-Blackwell (2018). (attach file txt) ', 1, 1, 1)
INSERT [dbo].[TUVUNG] ([VocabID], [TopicID], [Frequency], [Word], [IPA], [Label], [Lemma], [Vietnamese], [Cluster], [Position], [Example], [VN_Example], [Resources], [Active], [Learned], [Level]) VALUES (4, 2, 1, 'low', 'N/ləʊ /', 'adjective', 'lower; 
lowly (adv)"', N'thấp, nhỏ', N'rate', N'on left', N'Most studies with LABA/LAMA combinations have been performed in patients with a low rate of exacerbations. ', N'Hầu hết các nghiên cứu với sự kết hợp LABA và LAMA đã được thực hiện ở những bệnh nhân lên cơn cấp với tần suất thấp.', 'GLOBAL STRATEGY FOR THE DIAGNOSIS, MANAGEMENT, AND PREVENTION OF CHRONIC OBSTRUCTIVE PULMONARY DISEASE (2018 REPORT). (attach file txt) ', 1, 1, 1)
INSERT [dbo].[TUVUNG] ([VocabID], [Frequency], [Word], [IPA], [Label], [Lemma], [Vietnamese], [Cluster], [Position], [Example], [VN_Example], [Resources], [Active], [Learned], [Level]) VALUES (5, 1, N'clinical', N'/kl??n??n /', N'adverb', N'clinical', N'lâm sàng, thuộc hoặc liên quan đến việc khám và điều trị bệnh nhân', 'clinical diagnosis', 'on left', 'The risk of misdiagnosis and over-treatment of individual patients using the fixed ratio (FEV1/FVC) as a diagnostic criterion is limited, as spirometry is only one parameter for establishing the clinical diagnosis of COPD', N'Nguy cơ chẩn đoán sai và điều trị quá mức đối ở từng bệnh nhân sử dụng fixed ratio (FEV1/FVC) làm tiêu chuẩn chẩn đoán thì còn hạn chế, vì phế dung kế chỉ là một trong các thông số đùng trong chẩn đoán lâm sàng của bệnh COPD', 'GLOBAL STRATEGY FOR THE DIAGNOSIS, MANAGEMENT, AND PREVENTION OF CHRONIC OBSTRUCTIVE PULMONARY DISEASE (2018 REPORT). (attach file txt) ', 1, 1, 1)
SET IDENTITY_INSERT [dbo].[TUVUNG] OFF

go


SET IDENTITY_INSERT [dbo].[TUVUNGCANHAN] ON 
INSERT [dbo].[TUVUNGCANHAN] (PersonalVocabID,PersonalVocabName, AccountID, IsDefault ) VALUES(1, 'My great word', 1, 1 )
SET IDENTITY_INSERT [dbo].[TUVUNGCANHAN] OFF

GO



SET IDENTITY_INSERT [dbo].[CAUAPDUNG] ON 
INSERT [dbo].[CAUAPDUNG] ([EXID], [Example], [VocabID]) VALUES (1, N'example 1', 1)
INSERT [dbo].[CAUAPDUNG] ([EXID], [Example], [VocabID]) VALUES (2, N'example 2', 2)
SET IDENTITY_INSERT [dbo].[CAUAPDUNG] OFF


-- HOC CHU DE
SET IDENTITY_INSERT [dbo].[OTP] ON 
INSERT [dbo].[OTP] ([ID], [AccountID], [OTPCODE], [CreatedAt], [ExpiredAt]) VALUES (2, 2, N'xyz', CAST(N'2023-02-20T00:00:00.000' AS DateTime), CAST(N'2024-02-20T00:00:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[OTP] OFF
GO

