-- Uwaga: Tresc zadania znajduje sie na dysku google w folderze Oracle_Przykladowy_Import_Danych. Link umieszczony w CV.

Truncate table MiastoExel;
Truncate table LotExel;
Truncate table SamolotExel;
Truncate table PasazerExel;
Truncate table Lot_PasazerExel;
Truncate table Lot_Pasazer;
Drop table Lot_Pasazer;
Drop table Lot;
Drop table Miasto;
Drop table Samolot;
Drop table Pasazer;
Drop table MiastoExel;
Drop table LotExel;
Drop table SamolotExel;
Drop table PasazerExel;
Drop table Lot_PasazerExel;
Drop SEQUENCE seq_Miasto;
Drop SEQUENCE seq_Samolot;
Drop SEQUENCE seq_Lot;
Drop SEQUENCE seq_Pasazer;
DROP VIEW AktualnyWidokBazyDanych;

-- 1. Tworzę tabele (na podstawie diagramu związków encji umieszczonego w pdf na dysku google) oraz sekwencje. 
-- Kod tworzy obiekty, które rozpoczynaja sie od 1 i powoduja przyrost o 1. Buforowanie ustawione jest na 10 wartosci.
SET TRANSACTION NAME 'Zadanie';
-- Tabela: Miasto
CREATE TABLE Miasto (
    IdMiasto int  NOT NULL PRIMARY KEY,
    NazwaMiasta varchar2(20)  NOT NULL
);

CREATE SEQUENCE seq_Miasto
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;
                          
-- Tabela: Samolot
CREATE TABLE Samolot (
    IdSamolot int  NOT NULL PRIMARY KEY,
    NazwaSamolotu varchar2(20)  NOT NULL
);

CREATE SEQUENCE seq_Samolot
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;

-- Tabela: Lot
CREATE Table Lot (
    IdLot int  NOT NULL PRIMARY KEY,
    GodzinaOdlotu timestamp  NOT NULL,
    Miasto_IdMiasto int  NOT NULL,
    Samolot_IdSamolot int  NOT NULL,
	CONSTRAINT Lot_Miasto FOREIGN KEY (Miasto_IdMiasto) REFERENCES Miasto (IdMiasto),
	CONSTRAINT Lot_Samolot FOREIGN KEY (Samolot_IdSamolot) REFERENCES Samolot (IdSamolot)
);

CREATE SEQUENCE seq_Lot
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;

-- Tabela: Pasazer
CREATE TABLE Pasazer (
    IdPasazer int  NOT NULL PRIMARY KEY,
    Imie varchar2(20)  NOT NULL,
    Nazwisko varchar2(20)  NOT NULL,
    Pesel  varchar2(11)  NOT NULL,
    Uwagi varchar2(20)  NULL
);

CREATE SEQUENCE seq_Pasazer
MINVALUE 1
START WITH 1
INCREMENT BY 1
CACHE 10;

-- Tabela: Lot_Pasazer
CREATE Table Lot_Pasazer (
    Pasazer_IdPasazer int  NOT NULL,
    Lot_IdLot int  NOT NULL,
	CONSTRAINT Lot_Pasazer_Lot FOREIGN KEY (Lot_IdLot) REFERENCES Lot (IdLot),
	CONSTRAINT Lot_Pasazer_Pasazer FOREIGN KEY (Pasazer_IdPasazer) REFERENCES Pasazer (IdPasazer)
);

CREATE VIEW AktualnyWidokBazyDanych AS
select a.IdLot, a.GodzinaOdlotu, c.*, d.NazwaMiasta, e.NazwaSamolotu
from Lot a
inner join Lot_Pasazer b
on a.IdLot = b.Lot_IdLot
inner join Pasazer c
on c.IdPasazer = b.Pasazer_IdPasazer
inner join Miasto d 
on d.IdMiasto = a.Miasto_IdMiasto
inner join Samolot e
on e.IdSamolot = a.Samolot_IdSamolot;

-- 2. Wstawiam przykładowe dane do tabel.

insert into Miasto values (seq_Miasto.nextval,'Warszawa');
insert into Samolot values (seq_Samolot.nextval,'Boeing 747');
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-RRRR';
insert into Lot values (seq_Lot.nextval,to_timestamp ( '2018-07-23 09:00:00.123', 'YYYY-MM-DD HH:MI:SS.FF' ),1,1);
insert into Pasazer values (seq_Pasazer.nextval,'Adam', 'XY', 12345678901, null);
insert into Lot_Pasazer values (1,1);


SAVEPOINT UtoworzonoBazeDanych;

-- 3. Tworzę tabele tymczasowych w celu 'importu tabel' do bazy danych. 
-- Nie używałem tutaj tabel zewnetrznych ze względu na to, że osoba czytająca plik z jakiegoś powodu, może nie mieć uprawnień do wczytania danych.

CREATE GLOBAL TEMPORARY TABLE MiastoExel
    ("IdMiasto" int, "NazwaMiasta" varchar2(10))
ON COMMIT PRESERVE ROWS;
INSERT ALL 
    INTO MiastoExel ("IdMiasto", "NazwaMiasta")
         VALUES (1, 'Waszyngton')
SELECT * FROM dual;

CREATE GLOBAL TEMPORARY TABLE LotExel
    ("IdLot" int, "GodzinaOdlotu" timestamp, "Miasto_IdMiasto" int, "Samolot_IdSamolot" int)
ON COMMIT PRESERVE ROWS;
INSERT ALL 
    INTO LotExel ("IdLot", "GodzinaOdlotu", "Miasto_IdMiasto", "Samolot_IdSamolot")
         VALUES (1, to_timestamp ( '2018-07-24 09:00:00.123', 'YYYY-MM-DD HH:MI:SS.FF' ), 1, 1)
    INTO LotExel ("IdLot", "GodzinaOdlotu", "Miasto_IdMiasto", "Samolot_IdSamolot")
         VALUES (2, to_timestamp ( '2018-07-25 09:00:00.123', 'YYYY-MM-DD HH:MI:SS.FF' ), 1, 1)
SELECT * FROM dual;

CREATE GLOBAL TEMPORARY TABLE SamolotExel
    ("IdSamolot" int, "NazwaSamolotu" varchar2(20))
ON COMMIT PRESERVE ROWS;
INSERT ALL 
    INTO SamolotExel ("IdSamolot", "NazwaSamolotu")
         VALUES (1, 'Lockheed L-1011')
    INTO SamolotExel ("IdSamolot", "NazwaSamolotu")
         VALUES (2, 'Airbus A220')
SELECT * FROM dual;

CREATE GLOBAL TEMPORARY TABLE PasazerExel
    ("IdPasazer" int, "Imie" varchar2(20), "Nazwisko" varchar2(20), "Pesel" varchar2(11), "Uwagi" varchar2(20) null)
ON COMMIT PRESERVE ROWS;
INSERT ALL 
    INTO PasazerExel ("IdPasazer", "Imie", "Nazwisko", "Pesel", "Uwagi")
         VALUES (1, 'Tomasz','Z',10987654321,null)
    INTO PasazerExel ("IdPasazer", "Imie", "Nazwisko", "Pesel", "Uwagi")
         VALUES (2, 'Agata','Y',54321610987,null)
SELECT * FROM dual;

CREATE GLOBAL TEMPORARY TABLE Lot_PasazerExel
    ("Pasazer_IdPasazer" int, "Lot_IdLot" int)
ON COMMIT PRESERVE ROWS;
INSERT INTO Lot_PasazerExel ("Pasazer_IdPasazer", "Lot_IdLot")
         VALUES (1, 1);

SAVEPOINT UtoworzonoTabeleTymczasowe;

-- 4. Dodaję kolumny przechowujących stare id z tabel tymczasowych; Wstawiam dane z tabeli tymczasowej do tabel znajdujących się w bazie danych.

ALTER TABLE Miasto
ADD StaryIdMiasto int null;

INSERT INTO Miasto (IdMiasto, NazwaMiasta, StaryIdMiasto)
SELECT seq_Miasto.nextval, "NazwaMiasta" , "IdMiasto"
FROM MiastoExel;

ALTER TABLE Lot
ADD Stary_Id_Lot int null;

INSERT INTO Lot (IdLot, GodzinaOdlotu, Miasto_IdMiasto, Samolot_IdSamolot, Stary_Id_Lot)
SELECT seq_Lot.nextval, "GodzinaOdlotu" , "Miasto_IdMiasto", "Samolot_IdSamolot", "IdLot"
FROM LotExel;

ALTER TABLE Samolot
ADD Stary_Id_Samolot int null;

INSERT INTO Samolot (IdSamolot, NazwaSamolotu , Stary_Id_Samolot)
SELECT seq_Samolot.nextval, "NazwaSamolotu", "IdSamolot"
FROM SamolotExel;

Alter Table Pasazer
Add Stary_Id_Pasazer int null;

INSERT INTO Pasazer (IdPasazer, Imie, Nazwisko, Pesel, Uwagi, Stary_Id_Pasazer)
SELECT seq_Pasazer.nextval, "Imie", "Nazwisko", "Pesel", "Uwagi", "IdPasazer"
FROM PasazerExel;

Alter Table Lot_Pasazer
Add NoweDaneExel_Lot_Pasazer varchar2(4) null;


INSERT INTO Lot_Pasazer (Pasazer_IdPasazer, Lot_IdLot, NoweDaneExel_Lot_Pasazer)
SELECT "Pasazer_IdPasazer", "Lot_IdLot", 'Exel'
FROM Lot_PasazerExel;

SAVEPOINT DodanoDaneDoBazyDanych;

-- 5. Aktualizuję stare klucze, które odpowiadały kluczom z tabeli tymczasowej oraz skasowałem kolumny w których znajdowały się stare klucze

Merge into (
select Stary_Id_Lot, Miasto_IdMiasto, nvl(Miasto_IdMiasto, Miasto_IdMiasto) nvl_Miasto_IdMiasto
from Lot) lot
Using (
Select StaryIDMiasto, IdMiasto
from Miasto) miasto
on (miasto.StaryIDMiasto = lot.nvl_Miasto_IdMiasto)
When Matched 
Then Update
set lot.Miasto_IdMiasto = miasto.IdMiasto
where lot.Stary_Id_Lot is not null;

ALTER TABLE miasto
DROP COLUMN StaryIdMiasto;

Merge into (
select Stary_Id_Lot, Samolot_IdSamolot, nvl(Samolot_IdSamolot, Samolot_IdSamolot) nvl_Samolot_IdSamolot
from Lot) lot
Using (
Select Stary_ID_Samolot, IdSamolot
from Samolot) samolot
on (samolot.Stary_ID_Samolot = lot.nvl_Samolot_IdSamolot)
When Matched 
Then Update
set lot.Samolot_IdSamolot = samolot.IdSamolot
where lot.Stary_Id_Lot is not null;

ALTER TABLE samolot
DROP COLUMN Stary_Id_Samolot;

Merge into (
select NoweDaneExel_Lot_Pasazer, Lot_IdLot, nvl(Lot_IdLot, Lot_IdLot) nvl_Lot_IdLot
from Lot_Pasazer) lot_pasazer
Using (
Select Stary_ID_Lot, IdLot
from Lot) lot
on (lot.Stary_ID_Lot = lot_pasazer.nvl_Lot_IdLot)
When Matched 
Then Update
set lot_pasazer.Lot_IdLot = lot.IdLot
where lot_pasazer.NoweDaneExel_Lot_Pasazer is not null;

ALTER TABLE lot
DROP COLUMN Stary_Id_Lot;

Merge into (
select NoweDaneExel_Lot_Pasazer, Pasazer_IdPasazer, nvl(Pasazer_IdPasazer, Pasazer_IdPasazer) nvl_Pasazer_IdPasazer
from Lot_Pasazer) lot_pasazer
Using (
Select Stary_ID_Pasazer, IdPasazer
from Pasazer) pasazer
on (pasazer.Stary_ID_Pasazer = lot_pasazer.nvl_Pasazer_IdPasazer)
When Matched 
Then Update
set lot_pasazer.Pasazer_IdPasazer = pasazer.IdPasazer
where lot_pasazer.NoweDaneExel_Lot_Pasazer is not null;

ALTER TABLE pasazer
DROP COLUMN Stary_Id_Pasazer;

ALTER TABLE lot_pasazer
    DROP COLUMN NoweDaneExel_Lot_Pasazer;

commit;

Select * from AktualnyWidokBazyDanych;







