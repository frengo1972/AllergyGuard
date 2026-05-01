-- Seed iniziale del catalogo allergeni remoto.
-- Da eseguire dopo la migration 00004_allergen_catalog_sync.sql
-- quando vuoi inizializzare Supabase con il catalogo attualmente presente nel bundle.

WITH raw_catalog AS (
  SELECT
    $${
      "version":2,
      "allergens":[
        {"id":1,"name_key":"gluten","names":{"it":"glutine","en":"gluten","de":"Gluten","fr":"gluten","es":"gluten","pt":"gl\u00faten","nl":"gluten","pl":"gluten","cs":"lepek","hu":"glut\u00e9n","ro":"gluten","sv":"gluten","da":"gluten","fi":"gluteeni","el":"\u03b3\u03bb\u03bf\u03c5\u03c4\u03ad\u03bd\u03b7","ja":"\u30b0\u30eb\u30c6\u30f3","zh":"\u9eb8\u8d28","ko":"\uae00\ub8e8\ud150","ar":"\u063a\u0644\u0648\u062a\u064a\u0646","tr":"gluten"},"severity":"high","eu_regulated":true},
        {"id":2,"name_key":"peanut","names":{"it":"arachidi","en":"peanuts","de":"Erdn\u00fcsse","fr":"arachides","es":"cacahuetes","pt":"amendoins","nl":"pinda's","pl":"orzeszki ziemne","cs":"ara\u0161\u00eddy","hu":"f\u00f6ldimogyor\u00f3","ro":"arahide","sv":"jordn\u00f6tter","da":"jordn\u00f8dder","fi":"maap\u00e4hkin\u00e4t","el":"\u03b1\u03c1\u03ac\u03c0\u03b9\u03ba\u03b1 \u03c6\u03b9\u03c3\u03c4\u03af\u03ba\u03b9\u03b1","ja":"\u30d4\u30fc\u30ca\u30c3\u30c4","zh":"\u82b1\u751f","ko":"\ub545\ucf69","ar":"\u0641\u0648\u0644 \u0633\u0648\u062f\u0627\u0646\u064a","tr":"yer f\u0131st\u0131\u011f\u0131"},"search_terms":{"it":["arachide","noccioline americane"],"en":["peanut","groundnut","groundnuts"],"de":["Erdnuss"],"fr":["arachide","cacahu\u00e8te","cacahu\u00e8tes"],"es":["cacahuete","cacahuate","cacahuates","man\u00ed","mani"],"pt":["amendoim"],"nl":["pinda","pindas","aardnoot","aardnoten"],"pl":["orzeszek ziemny","fistaszki","fistaszek"],"cs":["ara\u0161\u00edd","bur\u00e1k","bur\u00e1ky"],"ro":["arahid\u0103","alune americane"],"sv":["jordn\u00f6t"],"da":["jordn\u00f8d"],"fi":["maap\u00e4hkin\u00e4"],"el":["\u03b1\u03c1\u03ac\u03c0\u03b9\u03ba\u03bf \u03c6\u03b9\u03c3\u03c4\u03af\u03ba\u03b9"],"zh":["\u82b1\u751f\u4ec1"]},"severity":"high","eu_regulated":true},
        {"id":3,"name_key":"milk","names":{"it":"latticini","en":"dairy","de":"Milchprodukte","fr":"produits laitiers","es":"l\u00e1cteos","pt":"latic\u00ednios","nl":"zuivel","pl":"nabia\u0142","cs":"ml\u00e9\u010dn\u00e9 v\u00fdrobky","hu":"tejterm\u00e9kek","ro":"lactate","sv":"mejeriprodukter","da":"mejeriprodukter","fi":"maitotuotteet","el":"\u03b3\u03b1\u03bb\u03b1\u03ba\u03c4\u03bf\u03ba\u03bf\u03bc\u03b9\u03ba\u03ac","ja":"\u4e73\u88fd\u54c1","zh":"\u4e73\u5236\u54c1","ko":"\uc720\uc81c\ud488","ar":"\u0645\u0646\u062a\u062c\u0627\u062a \u0627\u0644\u0623\u0644\u0628\u0627\u0646","tr":"s\u00fct \u00fcr\u00fcnleri"},"search_terms":{"it":["latte","prodotto lattiero-caseario","prodotti lattiero-caseari"],"en":["milk","dairy products","milk products"],"de":["Milch"],"fr":["lait"],"es":["leche","productos l\u00e1cteos"],"pt":["leite","latic\u00ednio","lactic\u00ednio","lactic\u00ednios","produtos l\u00e1cteos"],"nl":["melk","zuivelproducten"],"pl":["mleko","produkty mleczne"],"cs":["ml\u00e9ko"],"hu":["tej"],"ro":["lapte","produse lactate"],"sv":["mj\u00f6lk"],"da":["m\u00e6lk"],"fi":["maito"],"el":["\u03b3\u03ac\u03bb\u03b1"],"ja":["\u725b\u4e73","\u4e73"],"zh":["\u725b\u5976","\u4e73"],"ko":["\uc6b0\uc720"],"ar":["\u062d\u0644\u064a\u0628"],"tr":["s\u00fct"]},"severity":"high","eu_regulated":true},
        {"id":4,"name_key":"egg","names":{"it":"uova","en":"eggs","de":"Eier","fr":"\u0153ufs","es":"huevos","pt":"ovos","nl":"eieren","pl":"jaja","cs":"vejce","hu":"toj\u00e1s","ro":"ou\u0103","sv":"\u00e4gg","da":"\u00e6g","fi":"kananmunat","el":"\u03b1\u03c5\u03b3\u03ac","ja":"\u5375","zh":"\u9e21\u86cb","ko":"\ub2ec\uac40","ar":"\u0628\u064a\u0636","tr":"yumurta"},"severity":"high","eu_regulated":true},
        {"id":5,"name_key":"tree_nut","names":{"it":"frutta a guscio","en":"tree nuts","de":"Schalenfr\u00fcchte","fr":"fruits \u00e0 coque","es":"frutos de c\u00e1scara","pt":"frutos de casca rija","nl":"noten","pl":"orzechy","cs":"sko\u0159\u00e1pkov\u00e9 plody","hu":"di\u00f3f\u00e9l\u00e9k","ro":"fructe cu coaj\u0103","sv":"n\u00f6tter","da":"n\u00f8dder","fi":"p\u00e4hkin\u00e4t","el":"\u03be\u03b7\u03c1\u03bf\u03af \u03ba\u03b1\u03c1\u03c0\u03bf\u03af","ja":"\u30ca\u30c3\u30c4\u985e","zh":"\u575a\u679c","ko":"\uacac\uacfc\ub958","ar":"\u0645\u0643\u0633\u0631\u0627\u062a","tr":"kabuklu yemi\u015fler"},"severity":"high","eu_regulated":true},
        {"id":6,"name_key":"soy","names":{"it":"soia","en":"soybeans","de":"Soja","fr":"soja","es":"soja","pt":"soja","nl":"soja","pl":"soja","cs":"s\u00f3ja","hu":"sz\u00f3ja","ro":"soia","sv":"soja","da":"soja","fi":"soija","el":"\u03c3\u03cc\u03b3\u03b9\u03b1","ja":"\u5927\u8c46","zh":"\u5927\u8c46","ko":"\ub300\ub450","ar":"\u0641\u0648\u0644 \u0627\u0644\u0635\u0648\u064a\u0627","tr":"soya"},"severity":"high","eu_regulated":true},
        {"id":7,"name_key":"fish","names":{"it":"pesce","en":"fish","de":"Fisch","fr":"poisson","es":"pescado","pt":"peixe","nl":"vis","pl":"ryby","cs":"ryby","hu":"hal","ro":"pe\u0219te","sv":"fisk","da":"fisk","fi":"kala","el":"\u03c8\u03ac\u03c1\u03b9","ja":"\u9b5a","zh":"\u9c7c","ko":"\uc0dd\uc120","ar":"\u0633\u0645\u0643","tr":"bal\u0131k"},"severity":"high","eu_regulated":true},
        {"id":8,"name_key":"crustacean","names":{"it":"crostacei","en":"crustaceans","de":"Krebstiere","fr":"crustac\u00e9s","es":"crust\u00e1ceos","pt":"crust\u00e1ceos","nl":"schaaldieren","pl":"skorupiaki","cs":"kor\u00fd\u0161i","hu":"r\u00e1kf\u00e9l\u00e9k","ro":"crustacee","sv":"kr\u00e4ftdjur","da":"krebsdyr","fi":"\u00e4yri\u00e4iset","el":"\u03ba\u03b1\u03c1\u03ba\u03b9\u03bd\u03bf\u03b5\u03b9\u03b4\u03ae","ja":"\u7532\u6bbb\u985e","zh":"\u7532\u58f3\u7c7b","ko":"\uac11\uac01\ub958","ar":"\u0642\u0634\u0631\u064a\u0627\u062a","tr":"kabuklu deniz hayvanlar\u0131"},"severity":"high","eu_regulated":true},
        {"id":9,"name_key":"mollusc","names":{"it":"molluschi","en":"molluscs","de":"Weichtiere","fr":"mollusques","es":"moluscos","pt":"moluscos","nl":"weekdieren","pl":"mi\u0119czaki","cs":"m\u011bkk\u00fd\u0161i","hu":"puhatest\u0171ek","ro":"molu\u0219te","sv":"bl\u00f6tdjur","da":"bl\u00f8ddyr","fi":"nilvi\u00e4iset","el":"\u03bc\u03b1\u03bb\u03ac\u03ba\u03b9\u03b1","ja":"\u8edf\u4f53\u52d5\u7269","zh":"\u8f6f\u4f53\u52a8\u7269","ko":"\uc5f0\uccb4\ub958","ar":"\u0631\u062e\u0648\u064a\u0627\u062a","tr":"yumu\u015fak\u00e7alar"},"severity":"high","eu_regulated":true},
        {"id":10,"name_key":"celery","names":{"it":"sedano","en":"celery","de":"Sellerie","fr":"c\u00e9leri","es":"apio","pt":"aipo","nl":"selderij","pl":"seler","cs":"celer","hu":"zeller","ro":"\u021belin\u0103","sv":"selleri","da":"selleri","fi":"selleri","el":"\u03c3\u03ad\u03bb\u03b9\u03bd\u03bf","ja":"\u30bb\u30ed\u30ea","zh":"\u82b9\u83dc","ko":"\uc140\ub7ec\ub9ac","ar":"\u0643\u0631\u0641\u0633","tr":"kereviz"},"severity":"medium","eu_regulated":true},
        {"id":11,"name_key":"mustard","names":{"it":"senape","en":"mustard","de":"Senf","fr":"moutarde","es":"mostaza","pt":"mostarda","nl":"mosterd","pl":"gorczyca","cs":"ho\u0159\u010dice","hu":"must\u00e1r","ro":"mu\u0219tar","sv":"senap","da":"sennep","fi":"sinappi","el":"\u03bc\u03bf\u03c5\u03c3\u03c4\u03ac\u03c1\u03b4\u03b1","ja":"\u30de\u30b9\u30bf\u30fc\u30c9","zh":"\u82a5\u672b","ko":"\uaca8\uc790","ar":"\u062e\u0631\u062f\u0644","tr":"hardal"},"severity":"medium","eu_regulated":true},
        {"id":12,"name_key":"sesame","names":{"it":"sesamo","en":"sesame","de":"Sesam","fr":"s\u00e9same","es":"s\u00e9samo","pt":"s\u00e9samo","nl":"sesam","pl":"sezam","cs":"sezam","hu":"szez\u00e1m","ro":"susan","sv":"sesam","da":"sesam","fi":"seesami","el":"\u03c3\u03bf\u03c5\u03c3\u03ac\u03bc\u03b9","ja":"\u3054\u307e","zh":"\u829d\u9ebb","ko":"\ucc38\uae68","ar":"\u0633\u0645\u0633\u0645","tr":"susam"},"severity":"medium","eu_regulated":true},
        {"id":13,"name_key":"sulphite","names":{"it":"solfiti","en":"sulphites","de":"Sulfite","fr":"sulfites","es":"sulfitos","pt":"sulfitos","nl":"sulfieten","pl":"siarczyny","cs":"oxid si\u0159i\u010dit\u00fd","hu":"szulfitok","ro":"sulfi\u021bi","sv":"sulfiter","da":"sulfitter","fi":"sulfiitit","el":"\u03b8\u03b5\u03b9\u03ce\u03b4\u03b7","ja":"\u4e9c\u786b\u9178\u5869","zh":"\u4e9a\u786b\u9178\u76d0","ko":"\uc544\ud669\uc0b0\uc5fc","ar":"\u0643\u0628\u0631\u064a\u062a\u0627\u062a","tr":"s\u00fclfitler"},"severity":"medium","eu_regulated":true},
        {"id":14,"name_key":"lupin","names":{"it":"lupini","en":"lupin","de":"Lupinen","fr":"lupin","es":"altramuces","pt":"tremo\u00e7os","nl":"lupine","pl":"\u0142ubin","cs":"vl\u010d\u00ed bob","hu":"csillagf\u00fcrt","ro":"lupin","sv":"lupin","da":"lupin","fi":"lupiini","el":"\u03bb\u03bf\u03cd\u03c0\u03b9\u03bd\u03bf","ja":"\u30eb\u30d4\u30ca\u30b9","zh":"\u7fbd\u6247\u8c46","ko":"\ub8e8\ud540","ar":"\u062a\u0631\u0645\u0633","tr":"ac\u0131 bakla"},"severity":"medium","eu_regulated":true}
      ]
    }$$::jsonb AS doc
),
upsert_allergens AS (
  INSERT INTO allergens (
    id,
    name_key,
    names,
    search_terms,
    severity,
    eu_regulated,
    icon_type,
    dataset_version,
    updated_at,
    is_active
  )
  SELECT
    (item->>'id')::INT AS id,
    item->>'name_key' AS name_key,
    item->'names' AS names,
    COALESCE(item->'search_terms', '{}'::jsonb) AS search_terms,
    COALESCE(item->>'severity', 'high') AS severity,
    COALESCE((item->>'eu_regulated')::BOOLEAN, false) AS eu_regulated,
    'bundle' AS icon_type,
    COALESCE((doc->>'version')::INT, 1) AS dataset_version,
    NOW() AS updated_at,
    true AS is_active
  FROM raw_catalog, jsonb_array_elements(doc->'allergens') AS item
  ON CONFLICT (id) DO UPDATE
  SET
    name_key = EXCLUDED.name_key,
    names = EXCLUDED.names,
    search_terms = EXCLUDED.search_terms,
    severity = EXCLUDED.severity,
    eu_regulated = EXCLUDED.eu_regulated,
    icon_type = EXCLUDED.icon_type,
    dataset_version = EXCLUDED.dataset_version,
    updated_at = EXCLUDED.updated_at,
    is_active = EXCLUDED.is_active
  RETURNING 1
)
INSERT INTO app_datasets (
  dataset_name,
  version,
  updated_at,
  summary,
  added_keys
)
SELECT
  'allergens',
  COALESCE((doc->>'version')::INT, 1),
  NOW(),
  'Bundled allergen catalog seeded from assets/allergens/allergen_list.json',
  '{}'::TEXT[]
FROM raw_catalog
ON CONFLICT (dataset_name) DO UPDATE
SET
  version = EXCLUDED.version,
  updated_at = EXCLUDED.updated_at,
  summary = EXCLUDED.summary,
  added_keys = EXCLUDED.added_keys;
