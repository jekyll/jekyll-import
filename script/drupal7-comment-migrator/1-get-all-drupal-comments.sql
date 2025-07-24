SELECT c.cid, c.nid, c.pid, c.name, c.created, cb.comment_body_value
FROM comment c
JOIN field_data_comment_body cb ON c.cid = cb.entity_id
ORDER BY c.nid, c.created;