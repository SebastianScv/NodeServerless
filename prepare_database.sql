create schema test_hst;
GRANT ALL ON SCHEMA test_hst TO public;

create table test_hst.audit (
    id serial primary key,
    event_user name NOT NULL DEFAULT "session_user"(),
    event_time timestamp with time zone NOT NULL DEFAULT now(),
    event_type text NOT NULL CHECK (event_type = ANY (ARRAY['INSERT', 'UPDATE', 'DELETE'])),
    table_name name NOT NULL,
    object_id bigint NOT NULL,
    record_new json,
    record_old json
);


insert into test_hst.audit(event_user, event_time, event_type, table_name, object_id, record_new, record_old)
values
	('borewicz.p', '2016-10-11 12:13'::timestamptz, 'INSERT', 'person', 13,
	 '{"id":13, "first_name":"Anna","last_name": "Kowalska", "bith": "1988-08-08", "pesel": null}'::json,
	 '{}'::json
	)
;

insert into test_hst.audit(event_user, event_time, event_type, table_name, object_id, record_new, record_old)
values
('borewicz.p', '2016-10-11 12:21'::timestamptz, 'INSERT', 'address', 13,
	 '{"id":13, "person_id": 13, "city": "Warszawa", "street": null, "code": null}'::json,
	 '{}'::json
	)
;

insert into test_hst.audit(event_user, event_time, event_type, table_name, object_id, record_new, record_old)
values
	('borewicz.p', '2016-10-11 12:33'::timestamptz, 'UPDATE', 'address', 13,
	 '{"id":13, "person_id": 13, "city": "Warszawa", "street": "Kwiatowa 13 / 1", "code": "00-128"}'::json,
	 '{"id":13, "person_id": 13, "city": "Warszawa", "street": null, "code": null}'::json
	)
;

insert into test_hst.audit(event_user, event_time, event_type, table_name, object_id, record_new, record_old)
values
	('adam.r', '2016-10-11 15:15'::timestamptz, 'UPDATE', 'person', 14,
	 '{"id":14, "first_name": "", "last_name": "Kowalska", "bith": "1978-04-05", "pesel": "78191919191"}'::json,
	 '{"id":14, "first_name": "Jan", "last_name": "Kowalski", "bith": "1978-04-04", "pesel": null}'::json
	)
;

insert into test_hst.audit(event_user, event_time, event_type, table_name, object_id, record_new, record_old)
values
	('klos.j', '2016-10-12 13:11'::timestamptz, 'UPDATE', 'person', 13,
	 '{"id":13, "first_name": "Anna", "last_name": "Kowalska", "bith": "1988-08-08", "pesel": "88080804322"}'::json,
	 '{"id":13, "first_name": "Anna", "last_name": "Kowalska", "bith": "1988-08-08", "pesel": null}'::json
	)
;

insert into test_hst.audit(event_user, event_time, event_type, table_name, object_id, record_new, record_old)
values
	('adam.k', '2016-10-12 13:11'::timestamptz, 'UPDATE', 'person', 15,
	 '{}'::json,
	 '{"id":15, "first_name": "Adam", "last_name": "Kowalski", "bith": "1948-04-04", "pesel": null}'::json
	)
;

insert into test_hst.audit(event_user, event_time, event_type, table_name, object_id, record_new, record_old)
values
	('borewicz.p', '2017-05-29 14:32'::timestamptz, 'UPDATE', 'person', 13,
	 '{"id":13, "first_name": "Anna", "last_name": "Skowron", "bith": "1988-08-08", "pesel": "88080804322"}'::json,
	 '{"id":13, "first_name": "Anna", "last_name": "Kowalska", "bith": "1988-08-08", "pesel": "88080804322"}'::json
	)
;

insert into test_hst.audit(event_user, event_time, event_type, table_name, object_id, record_new, record_old)
values
	('borewicz.p', '2017-05-29 14:31'::timestamptz, 'DELETE', 'address', 13,
	 '{}'::json,
	 '{"id":13, "person_id": 13, "city": "Warszawa", "street": "Kwiatowa 13 / 1", "code": "00-128"}'::json
	)
;

insert into test_hst.audit(event_user, event_time, event_type, table_name, object_id, record_new, record_old)
values
	('borewicz.p', '2017-05-29 14:32'::timestamptz, 'DELETE', 'person', 13,
	 '{}'::json,
	 '{"id":13, "first_name": "Anna", "last_name": "Skowron", "bith": "1988-08-08", "pesel": "88080804322"}'::json
	)
;

insert into test_hst.audit(event_user, event_time, event_type, table_name, object_id, record_new, record_old)
values
	('adam.k', '2016-10-12 13:11'::timestamptz, 'UPDATE', 'person', 15,
	'{"id":15, "first_name": "Adam", "last_name": "Kowalski", "bith": "1948-04-04", "pesel": null}'::json,
	 '{}'::json
	)
;
