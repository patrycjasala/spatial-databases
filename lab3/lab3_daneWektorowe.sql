-- 4. Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty)
-- położonych w odległości mniejszej niż 1000 m od głównych rzek. Budynki spełniające to
-- kryterium zapisz do osobnej tabeli tableB.

select distinct count(p.f_codedesc) from popp p, majrivers mr 
where st_dwithin(mr.geom, p.geom, 1000)
and p.f_codedesc = 'Building';

select p.* into tableB
from popp p, majrivers mr 
where st_dwithin(mr.geom, p.geom, 1000)
and p.f_codedesc = 'Building';


-- 5. Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich
-- geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.
-- a) Znajdź lotnisko, które położone jest najbardziej na zachód i najbardziej na wschód.
-- b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie środkowym drogi 
-- pomiędzy lotniskami znalezionymi w punkcie a. Lotnisko nazwij airportB. Wysokość n.p.m. przyjmij dowolną.
-- Uwaga: geodezyjny układ współrzędnych prostokątnych płaskich (x – oś pionowa, y – oś pozioma)

create table airportsNew
as (select name, geom, elev from airports); 

--lub
select name, geom, elev 
into airportsNew
from airports ;

select * from airportsNew
order by st_x(geom) desc
limit 1;

-- a
( select name, st_y(geom) from airportsNew
order by st_y(geom) desc limit 1 )
union
( select name, st_y(geom) from airportsNew
order by st_y(geom) limit 1 )


-- b
insert into airportsNew values(
'airportB', 
(select st_centroid(
	(st_shortestline(
		(select geom from airportsNew where name='NOATAK'), 
		(select geom from airportsNew where name='NIKOLSKI AS'))
	))
),
38
);

-- sprawdzenie
select * from airportsNew where name='airportB' or name='NOATAK' or name='NIKOLSKI AS';


-- 6. Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej
-- linii łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”

select st_area(st_buffer(st_shortestline(l.geom, a.geom), 1000))
from lakes l, airports a
where l.names='Iliamna Lake'
and a.name='AMBLER';


-- 7. Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących
-- poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps).

select tr.vegdesc, sum(st_area(tr.geom))
from trees tr, tundra tu, swamp sw
where st_within(tr.geom, tu.geom)
or st_within(tr.geom, sw.geom)
group by tr.vegdesc;
