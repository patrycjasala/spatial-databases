create database firma;
create schema ksiegowosc;

create table ksiegowosc.pracownicy(
	id_pracownika int primary key,
	imie varchar(30) not null,
	nazwisko varchar(30) not null,
	adres varchar(100),
	telefon varchar(12)
);
comment on table ksiegowosc.pracownicy
	is 'Pracownicy firmy, ich adresy oraz numery telefonow.';

create table ksiegowosc.godziny(
	id_godziny int primary key, 
	data date,
	liczba_godzin int,
	id_pracownika int not null,
	foreign key(id_pracownika) references ksiegowosc.pracownicy(id_pracownika)
);
comment on table ksiegowosc.godziny
	is 'Liczba przepracowanych godzin przez dana osobe w ciagu miesiaca';
comment on column ksiegowosc.godziny.data
	is 'Data rozliczenia liczby godzin - ostatni dzien miesiaca';

create table ksiegowosc.pensja(
	id_pensji int primary key,
	stanowisko varchar(50),
	kwota money not null
);
comment on table ksiegowosc.pensja 
	is 'Wysokosc pensji dla danego stanowiska';

create table ksiegowosc.premia(
	id_premii varchar(5) primary key,
	rodzaj varchar(50),
	kwota money not null
);
comment on table ksiegowosc.premia
	is 'Rodzaje premii przyznawanych do pensji oraz ich kwoty.';
comment on column ksiegowosc.premia.id_premii
	is 'Skrot od nazwy rodzaju premii. W przypadku nieuzyskania premii przez pracownika nalezy wybrac premie o id BRAK';

create table ksiegowosc.wynagrodzenie(
	id_wynagrodzenia int primary key,
	data date,
	id_pracownika int,
	id_godziny int,
	id_pensji int,
	id_premii varchar(5) not null,
	foreign key (id_pracownika) references ksiegowosc.pracownicy(id_pracownika),
	foreign key (id_godziny) references ksiegowosc.godziny(id_godziny), 
	foreign key (id_pensji) references ksiegowosc.pensja(id_pensji),
	foreign key (id_premii) references ksiegowosc.premia(id_premii)
);
comment on table ksiegowosc.wynagrodzenie 
	is 'Miesieczne wynagrodzenia dla pracowników uwzgledniajace pensje, premie oraz ilosci przepracowanych godzin w danym miesiacu.';
comment on column ksiegowosc.wynagrodzenie.data
	is 'Data wyplaty wynagrodzenia.';

insert into ksiegowosc.pracownicy 
values 
	(0, 'Adam', 'Mróz', 'Kraków ul. Wielicka 38/212A', '+48704256806'),
	(1, 'Aniela', 'Jankowska', 'Kraków ul. Focha 3/2', '+48745093495'),
	(2, 'Monika', 'Wróblewska', 'Kraków ul. Rynek 8F', '+48108680277'),
	(3, 'Mateusz', 'Lis', 'Kraków ul. Centralna 2/31', '+48716102496'),
	(4, 'Olga', 'Sawicka', 'Kraków ul. Mogilska 93/5', '+48535436595'),
	(5, 'Helena', 'Urbańska', 'Kraków ul. Szewska 21', '+48110312102'),
	(6, 'Artur ', 'Czerwiński', 'Kraków ul. Lea 3/13', '+48224648271'),
	(7, 'Zuzanna', 'Lis', 'Kraków ul. Królewska 41/3', '+48153834770'),
	(8, 'Mateusz', 'Kamiński', 'Kraków ul. Lea 3B/16', '+48881006747'),
	(9, 'Igor', 'Sikorski', 'Kraków ul. Szewska 4/3A', '+48776490526');

insert into ksiegowosc.godziny 
values 
	(0, '2021-03-31', 160, 0),
	(1, '2021-03-31', 140, 1),
	(2, '2021-03-31', 170, 2),
	(3, '2021-03-31', 150, 3),
	(4, '2021-03-31', 168, 4),
	(5, '2021-03-31', 180, 5),
	(6, '2021-02-26', 161, 6),
	(7, '2021-02-26', 162, 7),
	(8, '2021-02-26', 130, 8),
	(9, '2021-02-26', 160, 9);

insert into ksiegowosc.pensja 
values 
	(0, 'Kierownik', 11000),
	(1, 'Web Designer', 7200),
	(2, 'Specjalista ds. Sprzedaży', 5100),
	(3, 'Kierownik projektu', 5800),
	(4, 'Graphic Designer', 6700),
	(5, 'Junior Graphic Designer', 4200),
	(6, 'Copywriter', 4500),
	(7, 'Koordynator Kampanii Marketingowych', 5600),
	(8, 'Specjalista ds. Rekrutacji', 4300),
	(9, 'Księgowa', 3500);

insert into ksiegowosc.premia 
values 
	('PROM', 'Awans', 1000),
	('OVER', 'Nadgodziny', 200),
	('FREQ', 'Frekwencja', 100),
	('HLDAY', 'Praca w święta', 200),
	('PERF', 'Wydajność pracy', 200),
	('WKND', 'Praca w weekendy', 100),
	('MONTH', 'Comiesięczna premia', 30),
	('MTHW', 'Pracownik miesiąca', 400),
	('SNRT', 'Premia za staż', 300),
	('BRAK', 'Brak premii', 0);

insert into ksiegowosc.wynagrodzenie
values
	(0, '2021-04-05', 0, 0, 4, 'PERF'),
	(1, '2021-04-05', 1, 1, 5, 'OVER'),
	(2, '2021-04-05', 2, 2, 1, 'FREQ'),
	(3, '2021-04-05', 3, 3, 9, 'BRAK'),
	(4, '2021-04-05', 4, 4, 1, 'WKND'),
	(5, '2021-04-05', 5, 5, 2, 'PERF'),
	(6, '2021-03-06', 6, 6, 4, 'BRAK'),
	(7, '2021-03-06', 7, 7, 3, 'OVER'),
	(8, '2021-03-06', 8, 8, 1, 'SNRT'),
	(9, '2021-03-06', 9, 9, 0, 'OVER');


-- a wyswietl tylko id pracownika oraz jego nazwisko
select id_pracownika, nazwisko from ksiegowosc.pracownicy;

-- b wyswietl id pracownikow, których placa jest wieksza niz 1000
select id_pracownika, (pe.kwota+pr.kwota) as placa 
from ksiegowosc.wynagrodzenie w
	join ksiegowosc.pensja pe on pe.id_pensji=w.id_pensji
	join ksiegowosc.premia pr on pr.id_premii=w.id_premii
where pe.kwota+pr.kwota > '1000';

-- c wyswietl id pracownikow nieposiadajacych premii, ktorych placa jest wieksza niz 2000
select id_pracownika
from ksiegowosc.wynagrodzenie w
	join ksiegowosc.pensja pe on pe.id_pensji=w.id_pensji
	join ksiegowosc.premia pr on pr.id_premii=w.id_premii
where pe.kwota+pr.kwota > '2000'
and w.id_premii like 'BRAK';

-- d wyswietl pracownikow, ktorych pierwsza litera imienia zaczyna sie na litere ‘J’
select * from ksiegowosc.pracownicy
where imie like 'J%';

-- e wyswietl pracownikow, ktorych nazwisko zawiera litere ‘n’ oraz imie konczy sie na litere ‘a’
select * from ksiegowosc.pracownicy
where nazwisko like '%n%' and imie like '%a';

-- f wyswietl imie i nazwisko pracownikow oraz liczbe ich nadgodzin, przyjmujac, iz standardowy czas pracy to 160 h miesiecznie
select imie, nazwisko, (liczba_godzin-160) as nadgodziny from ksiegowosc.pracownicy pr
	join ksiegowosc.godziny g on pr.id_pracownika=g.id_pracownika
where liczba_godzin > 160;

-- g wyswietl imie i nazwisko pracownikow, ktorych pensja zawiera sie w przedziale 1500 – 3000PLN
select imie, nazwisko from ksiegowosc.pracownicy p
	join ksiegowosc.wynagrodzenie w on w.id_pracownika=p.id_pracownika
	join ksiegowosc.pensja pe on pe.id_pensji=w.id_pensji
where pe.kwota >= '5000' and pe.kwota <= '7000';

-- h wyswietl imie i nazwisko pracownikow, ktorzy pracowali w nadgodzinach i nie otrzymali premii
select imie, nazwisko from ksiegowosc.pracownicy p 
	join ksiegowosc.wynagrodzenie w on w.id_pracownika=p.id_pracownika
	join ksiegowosc.godziny g on g.id_pracownika=p.id_pracownika
where liczba_godzin > 160
and id_premii like 'BRAK';

-- i uszereguj pracownikow wedlug pensji
select p.id_pracownika, imie, nazwisko, kwota as pensja from ksiegowosc.pracownicy p
	join ksiegowosc.wynagrodzenie w on w.id_pracownika=p.id_pracownika
	join ksiegowosc.pensja pe on pe.id_pensji=w.id_pensji
order by pensja;

-- j uszereguj pracownikow wedlug pensji i premii malejaco
select p.id_pracownika, imie, nazwisko, pe.kwota as pensja, pr.kwota as premia
from ksiegowosc.pracownicy p
	join ksiegowosc.wynagrodzenie w on w.id_pracownika=p.id_pracownika
	join ksiegowosc.pensja pe on pe.id_pensji=w.id_pensji
	join ksiegowosc.premia pr on pr.id_premii=w.id_premii
order by pensja desc, premia desc;

-- k zlicz i pogrupuj pracownikow wedlug pola ‘stanowisko’
select stanowisko, count(id_pracownika) as ilosc_pracownikow from ksiegowosc.pensja pe
	join ksiegowosc.wynagrodzenie w on w.id_pensji=pe.id_pensji
group by stanowisko
order by ilosc_pracownikow desc;

-- l policz srednia, minimalna i maksymalna place dla stanowiska ‘kierownik’ (jezeli takiego nie masz, to przyjmij dowolne inne)
select (avg((pe.kwota+pr.kwota)::numeric))::money as srednia,
min(pe.kwota+pr.kwota) as minimalna,
max(pe.kwota+pr.kwota) as maksymalna
from ksiegowosc.wynagrodzenie w
	join ksiegowosc.pensja pe on pe.id_pensji=w.id_pensji
	join ksiegowosc.premia pr on pr.id_premii=w.id_premii
where stanowisko like 'Web Designer';

-- m policz sume wszystkich wynagrodzen
select sum(pe.kwota+pr.kwota) as suma
from ksiegowosc.wynagrodzenie w
	join ksiegowosc.pensja pe on pe.id_pensji=w.id_pensji
	join ksiegowosc.premia pr on pr.id_premii=w.id_premii;

-- n policz sume wynagrodzen w ramach danego stanowiska
select stanowisko, sum(pe.kwota+pr.kwota) as suma
from ksiegowosc.wynagrodzenie w
	join ksiegowosc.pensja pe on pe.id_pensji=w.id_pensji
	join ksiegowosc.premia pr on pr.id_premii=w.id_premii
group by stanowisko;

-- o wyznacz liczbe premii przyznanych dla pracownikow danego stanowiska
select stanowisko, count(pr.id_premii) as liczba_premii
from ksiegowosc.wynagrodzenie w
	join ksiegowosc.pensja pe on pe.id_pensji=w.id_pensji
	join ksiegowosc.premia pr on pr.id_premii=w.id_premii
where pr.id_premii not like 'BRAK'
group by stanowisko
order by liczba_premii desc;

-- p usun wszystkich pracownikow majacych pensje mniejsza niz 1200 zl
alter table ksiegowosc.godziny
drop constraint godziny_id_pracownika_fkey,
add constraint godziny_id_pracownika_fkey
   foreign key (id_pracownika) references ksiegowosc.pracownicy(id_pracownika)
   on delete cascade;

alter table ksiegowosc.wynagrodzenie
drop constraint wynagrodzenie_id_pracownika_fkey,
add constraint wynagrodzenie_id_pracownika_fkey
   foreign key (id_pracownika) references ksiegowosc.pracownicy(id_pracownika)
   on delete cascade;
   
delete from ksiegowosc.pracownicy
using ksiegowosc.wynagrodzenie, ksiegowosc.pensja
where ksiegowosc.wynagrodzenie.id_pracownika = ksiegowosc.pracownicy.id_pracownika
and ksiegowosc.pensja.id_pensji = ksiegowosc.wynagrodzenie.id_pensji
and kwota < '5000';

select * from ksiegowosc.pracownicy;

