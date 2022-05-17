def split_dict(d, n):
    n = min(n, len(d))
    if n:
        r = [dict() for i in range(n)]
        i = 0
        for k, v in d.items():
            r[i][k] = v
            if i<n-1:
                i += 1
            else:
                i = 0
        return r
    else:
        return []

def split_list(l, n):
    n = min(n, len(l))
    if n:
        return [l[i:i + n] for i in range(0, len(l), n)]
    else:
        return []

def split_list_bysize(l, sz):
    n = len(l) // sz
    if len(l) % sz:
        n += 1
    return split_list(l, n)

def ip_from_oid(oid):
    return '.'.join(oid.split('.')[-4:])

def hex_from_octets(octets):
    return ''.join([ '%0.2x' % ord(_) for _ in octets ]).upper()

def iter_leafs(d, prefix='', delimiter='_'):
    for k, v in d.items():
        if isinstance(v, dict):
            yield from iter_leafs(v, prefix=prefix+k+delimiter, delimiter=delimiter)
        else:
            yield prefix+k, v

def list_of_dicts_to_single_layer(src_list, delimiter='_'):
    dst_list = []
    for src_item in src_list:
        dst_item = {}
        for k, v in iter_leafs(src_item, delimiter=delimiter):
           if isinstance(v, list):
               dst_item[k.lower()] = str(v)
           else:
               dst_item[k.lower()] = v
        dst_list.append(dst_item)
    return dst_list

def union_list_of_sets(l):
    result = l.copy()
    changed = True
    while changed:
        i = 0
        changed = False
        while i<len(result):
            j = i + 1
            while j<len(result):
                if result[i] & result[j]:
                   changed = True
                   result[i] = result[i] | result[j]
                   del result[j]
                else:
                    j += 1
            i += 1
    return result