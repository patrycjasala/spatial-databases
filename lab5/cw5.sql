create schema lab5;

create table obiekty (
	name varchar not null,
    geom geometry not null
);

insert into obiekty values(
	'obiekt1',
	st_geomfromtext('compoundcurve( (0 1, 1 1), circularstring(1 1, 2 0, 3 1), circularstring(3 1, 4 2, 5 1), (5 1, 6 1) )')
), ( 
	'obiekt2',
	st_collect(
	array[
	'compoundcurve( (10 6, 14 6), circularstring(14 6, 16 4, 14 2),
			 circularstring(14 2, 12 0, 10 2), (10 2, 10 6))',
	'circularstring(11 2, 12 3, 13 2, 12 1, 11 2)'
	]) 
), (
	'obiekt3',
	st_geomfromtext(
	'multilinestring( (7 15, 10 17), (10 17, 12 13), (12 13, 7 15) )' ) 
), (
	'obiekt4',
	st_geomfromtext(
	'multilinestring( (20 20, 25 25), (25 25, 27 24), (27 24, 25 22), (25 22, 26 21), (26 21, 22 19), (22 19, 20.5 19.5))' ) 
), (
	'obiekt5',
	st_geomfromtext('multipoint(30 30 59, 38 32 234)') 
), (
	'obiekt6',
	st_collect(
	array[
	'linestring(1 1, 3 2)',
	'point(4 2)'
	]) 
);

select * from obiekty;


-- 1
select st_area(st_buffer(st_shortestline(o1.geom, o2.geom), 5))
from obiekty o1, obiekty o2
where o1.name = 'obiekt3' and o2.name = 'obiekt4';
	

-- 2
-- to make objekt4 a polygon the contour must be closed, there can't be a gap between the line ends

-- convert multicurve to linestring > add point to close the shape > convert to polygon
select st_makepolygon(st_addpoint(st_linemerge(st_curvetoline(geom)), st_startpoint(st_linemerge(st_curvetoline(geom))))) 
from obiekty 
where name = 'obiekt4';


-- 3 
insert into obiekty values(
	'obiekt7',
	(select st_collect(o1.geom, o2.geom) 
	from obiekty o1, obiekty o2 
	where o1.name = 'obiekt3' and o2.name = 'obiekt4'
	) 
);


-- 4
select name, st_area(st_buffer(geom, 5))
from obiekty
where not st_hasarc(geom);

