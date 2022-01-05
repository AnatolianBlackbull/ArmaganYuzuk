create database ArmaganYuzuk;

use ArmaganYuzuk;

create table Yuzuk(
     satici_id int not null,
	 urun_ad varchar(200) not null,
	 urun_id int not null,
	 stok_adet int not null,
	 fiyat int not null,
     cins varchar(50),
	 tas varchar(50));

create table Kullanici(
     musteri_id int not null,
	 ad varchar(50) not null,
	 soyad varchar(50) not null,
	 kullanici_ad varchar(100) not null,
	 kullanici_sifre varchar(50) not null,
	 eposta varchar(200) not null);

create table Satici(
	 satici_id int not null,
	 telefon int not null,
	 musteri_id int not null);

create table Satis(
     satis_id int not null,
	 urun_id int not null,
	 satis_miktar int not null,
	 musteri_id int not null,
	 satici_id int not null);

alter table Yuzuk
add constraint PK_Yuzuk
primary key (urun_id);

alter table Satici
add constraint PK_Satici
primary key (satici_id);

alter table Satis
add constraint PK_Satis
primary key (satis_id);

alter table Yuzuk
add constraint  FK_Yuzuk_Satici
foreign key (satici_id) references Satici(satici_id);

alter table Kullanici
add constraint PK_Kullanici
primary key (musteri_id);

alter table Satici
add constraint FK_Satici
foreign key (musteri_id) references Kullanici(musteri_id);

alter table Satis
add constraint FK_Satis_Urun
foreign key (urun_id) references Yuzuk(urun_id);

alter table Satis
add constraint FK_Satis_Satici
foreign key (satici_id) references Satici(satici_id);

alter table Satis
add constraint FK_Satis_Musteri
foreign key (musteri_id) references Kullanici(musteri_id);

go
create trigger Stok_Dusur --Satýþ yapýldýðýnda stoktan düþ
on Satis
for insert
as
begin
    declare @satilmis int, @satis_adet int;
    select @satilmis = urun_id, @satis_adet = satis_miktar
	from inserted;
    update Yuzuk set Yuzuk.stok_adet = (Yuzuk.stok_adet - @satis_adet)
    where Yuzuk.urun_id = @satilmis;
end
go

create trigger Satis_Engelle --Yeterli stok yoksa satýþý engelle
on Satis
after insert
as
if((select y.stok_adet
    from deleted d, Yuzuk y
    where d.urun_id = y.urun_id) = 0)
begin
    raiserror('Stokta ürün kalmamýþtýr.',1,1);
	rollback transaction;
end
go

create view SiparisGoruntule -- Sipariþin bilgilerini gözetlemek için
as
select a.IslemID ,concat(m.ad, ' ', m.soyad) as Satici, a.MusteriAd, a.UrunId, a.UrunAd, a.Adet, a.Fiyat
from 
(select ss.satis_id as IslemID ,st.musteri_id as SaticiMusteriID,
m.kullanici_ad as MusteriAd, y.urun_id as UrunId, y.urun_ad as UrunAd,
ss.satis_miktar as Adet, (ss.satis_miktar*y.fiyat) as Fiyat
from Satis ss, Satici st, Kullanici m, Yuzuk y
where ss.satici_id = st.satici_id and ss.musteri_id = m.musteri_id
and y.urun_id = ss.urun_id) a, Satis ss, Kullanici m
where a.SaticiMusteriID = m.musteri_id;