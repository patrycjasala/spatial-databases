create database bdp_lab2;
create extension postgis;
create schema map;

create table buildings (id int primary key, geometry geometry not null, name varchar not null);
create table roads (id int primary key, geometry geometry not null, name varchar not null);
create table poi (id int primary key, geometry geometry not null, name varchar not null);

insert into map.buildings values
	(1, ST_GeomFromText('polygon((8 1.5, 8 4, 10.5 4, 10.5 1.5, 8 1.5))'), 'BuildingA'),
	(2, ST_GeomFromText('polygon((4 5, 4 7, 6 7, 6 5, 4 5))'), 'BuildingB'),
	(3, ST_GeomFromText('polygon((3 6, 3 8, 5 8, 6 5, 3 6))'), 'BuildingC'),
	(4, ST_GeomFromText('polygon((9 8, 9 9, 10 9, 10 8, 9 8))'), 'BuildingD'),
	(5, ST_GeomFromText('polygon((1 1, 1 2, 2 2, 2 1, 1 1))'), 'BuildingF');

insert into map.roads values
	(1, ST_GeomFromText('linestring(0 4.5, 12 4.5)'), 'roadX'),
	(2, ST_GeomFromText('linestring(7.5 0, 7.5 10.5)'), 'roadY');
	
insert into map.poi values
	(1, ST_GeomFromText('point(1 3.5)'), 'G'),
	(2, ST_GeomFromText('point(5.5 1.5)'), 'H'),
	(3, ST_GeomFromText('point(6.5 5)'), 'I'),
	(4, ST_GeomFromText('point(6 9.5)'), 'J'),
	(5, ST_GeomFromText('point(9.5 6)'), 'K');
	
-- a. Wyznacz całkowitą długość dróg w analizowanym mieście.
select sum(st_length(geometry)) from map.roads;

-- b. Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego
--    budynek o nazwie BuildingA.
select st_asewkt(geometry), st_area(geometry), st_perimeter(geometry)
from map.buildings where name like 'BuildingA';

-- c. Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki.
--    Wyniki posortuj alfabetycznie.
select name, st_area(geometry) 
from map.buildings
order by name;

-- d. Wypisz nazwy i obwody 2 budynków o największej powierzchni.
select name, st_area(geometry) 
from map.buildings
order by st_area(geometry) desc
limit 2;

-- e. Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G.
select min(st_distance(b.geometry, p.geometry))
from map. buildings b, map.poi p
where b.name = 'BuildingC' and p.name = 'G';

-- f. Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się
--    w odległości większej niż 0.5 od budynku BuildingB.
select st_area(st_difference(
	(select geometry from map.buildings where name = 'BuildingC'),
	st_buffer(geometry, 0.5)))
from map.buildings where name = 'BuildingB';	

-- g. Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi o nazwie RoadX. 8.
select b.name from map.buildings b
where st_y(st_centroid(b.geometry)) > st_y(st_centroid((select geometry from map.roads where name = 'roadX')))

-- h. Oblicz pole powierzchni tych części budynku BuildingC i poligonu 
--    o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch obiektów.
select st_area(st_symdifference(
	geometry, 
	ST_GeomFromText('polygon((4 7, 6 7, 6 8, 4 8, 4 7))')
	))
from map.buildings 
where name like 'BuildingC';
