//
//  Project.m
//  HomeLand
//
//  Created by chao han on 14-3-5.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "Project.h"
#import "Projects.h"
#import "MeasureLayer.h"
#import "GPSLayer.h"
#import "EditLayer.h"
#import "FieldInfo.h"

@implementation Project

@synthesize opened;
@synthesize path;
@synthesize layers;

- (id)init
{
    if( (self = [super init]) )
    {
        spatialite_init(0);
    }
    return self;
}

-(BOOL) create:(NSString *)path;
{
    NSString *dataPath = [path stringByAppendingPathComponent:@"data.db"];

    
    int ret = sqlite3_open_v2 (dataPath.UTF8String, &_handle,
                           SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
    if (ret != SQLITE_OK)
    {
        sqlite3_close (_handle);
        return FALSE;
    }

    spatialite_init(0);
    
    /* showing the SQLite version */
    printf ("SQLite version: %s\n", sqlite3_libversion ());
    /* showing the SpatiaLite version */
    printf ("SpatiaLite version: %s\n", spatialite_version ());
    printf ("\n\n");
    
    char *err_msg = NULL;
    char sql[256];
    strcpy (sql, "select InitSpatialMetadata()");
    ret = sqlite3_exec (_handle, sql, NULL, NULL, &err_msg);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("InitSpatialMetadata() error: %s\n", err_msg);
        sqlite3_free (err_msg);
        return FALSE;
    }
    
    [self createBaseLayer];
    [self createGPSLayer:path];
    [self createLayer:@"Region" type:AGSGeometryTypePolygon];
    [self createLayer:@"Line" type:AGSGeometryTypePolyline];
    [self createLayer:@"Point" type:AGSGeometryTypePoint];
    
    [self createPhotoLayer:path];
    
    self.path = path;
    
    NSLog(@"project path %@", self.path);
    return TRUE;
}

- (BOOL) createLayer:(NSString*)name type:(AGSGeometryType)geometryType
{
    int ret = 0;
    char *err_msg = NULL;
    char sql[256];
    /*
     now we can create the test table
     for simplicity we'll define only one column, the primary key
     */
    strcpy (sql, "CREATE TABLE ");
    strcat (sql, name.UTF8String);
    strcat (sql, " (");
    strcat (sql, "id INTEGER NOT NULL PRIMARY KEY, name varchar ( 256 ) ,time timestamp, photoname varchar ( 256 ), field1 varchar ( 256 ),field2 varchar ( 256 ),field3 varchar ( 256 ) )");
    ret = sqlite3_exec (_handle, sql, NULL, NULL, &err_msg);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("CREATE TABLE 'test' error: %s\n", err_msg);
        sqlite3_free (err_msg);
        return FALSE;
    }
    
    
    /*
     ... we'll add a Geometry column of POINT type to the test table
     */
    strcpy (sql, "SELECT AddGeometryColumn('");
    strcat (sql, name.UTF8String);
    if (geometryType == AGSGeometryTypePoint) {
        strcat (sql, "', 'geom', 4326, 'POINT', 2)");
    }
    else if(geometryType == AGSGeometryTypePolyline)
    {
        strcat (sql, "', 'geom', 4326, 'LINESTRING', 2)");
    }
    else if(geometryType == AGSGeometryTypePolygon)
    {
        strcat (sql, "', 'geom', 4326, 'POLYGON', 2)");
    }
    
    ret = sqlite3_exec (_handle, sql, NULL, NULL, &err_msg);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("AddGeometryColumn() error: %s\n", err_msg);
        sqlite3_free (err_msg);
        return FALSE;
    }
    
    strcpy (sql, "alter TABLE Photo add filename varchar ( 256 )");
    ret = sqlite3_exec (_handle, sql, NULL, NULL, &err_msg);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("alter error: %s\n", err_msg);
        sqlite3_free (err_msg);
        return FALSE;
    }
    
    
    /*
     and finally we'll enable this geo-column to have a Spatial Index based on R*Tree
     */
    strcpy (sql, "SELECT CreateSpatialIndex('");
    strcat (sql, name.UTF8String);
    strcat (sql, "', 'geom')");
    ret = sqlite3_exec (_handle, sql, NULL, NULL, &err_msg);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("CreateSpatialIndex() error: %s\n", err_msg);
        sqlite3_free (err_msg);
        return FALSE;
    }
    
    AGSGraphicsLayer *graphicsLayer= [[AGSGraphicsLayer alloc] init];
    [self.mapView addMapLayer:graphicsLayer withName:name];
    
    return TRUE;
}

- (BOOL) openLayer:(NSString*)name type:(AGSGeometryType)geometryType
{
    int ret = 0;
    char *err_msg = NULL;
    char sql[256];
    
    sqlite3_stmt *stmt;
    
    gaiaGeomCollPtr geom;
    int ic;
    int n_rows;
    int n_columns;
    int row_no;
    const unsigned char *blob;
    int blob_size;
    int geom_type;
  
    sprintf (sql, "SELECT * FROM %s", name.UTF8String);
    
    ret = sqlite3_prepare_v2 (_handle, sql, strlen (sql), &stmt, NULL);
    if (ret != SQLITE_OK)
    {
        /* some error occurred */
		printf ("query#2 SQL error: %s\n", sqlite3_errmsg (_handle));
		return FALSE;
    }
    
    /* we'll now save the #columns within the result set */
    n_columns = sqlite3_column_count (stmt);
    row_no = 0;
    
    
    AGSGraphicsLayer *graphicsLayer= [[AGSGraphicsLayer alloc] init];
    
    AGSCalloutTemplate* calloutTemplate = [[AGSCalloutTemplate alloc] init] ;
    calloutTemplate.titleTemplate = @"${NAME}"; //show the value for attribute key 'CITY_NAME'
    calloutTemplate.detailTemplate = @"${POPULATION}"; //show the value for attribute key 'POPULATION'
    graphicsLayer.calloutDelegate = calloutTemplate;
    
    [self.mapView addMapLayer:graphicsLayer withName:name];
    
    AGSSymbol *symbol;
    
    if (geometryType == AGSGeometryTypePoint) {
        
        AGSSimpleMarkerSymbol* myMarkerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
        myMarkerSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        
        symbol = myMarkerSymbol;
    }
    else if(geometryType == AGSGeometryTypePolyline)
    {
        AGSSimpleFillSymbol* myFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        myFillSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        //线的边框还是“线”
        AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
        myOutlineSymbol.color = [UIColor redColor];
        myOutlineSymbol.width = 2;
        //set the outline property to myOutlineSymbol
        myFillSymbol.outline = myOutlineSymbol;
        
        symbol = myFillSymbol;
    }
    else if(geometryType == AGSGeometryTypePolygon)
    {
        AGSSimpleFillSymbol* myFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        myFillSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        //线的边框还是“线”
        AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
        myOutlineSymbol.color = [UIColor redColor];
        myOutlineSymbol.width = 2;
        //set the outline property to myOutlineSymbol
        myFillSymbol.outline = myOutlineSymbol;
        
        symbol = myFillSymbol;
    }
    
    while (1)
    {
        /* this is an infinite loop, intended to fetch any row */
        
        /* we are now trying to fetch the next available row */
		ret = sqlite3_step (stmt);
		if (ret == SQLITE_DONE)
        {
            /* there are no more rows to fetch - we can stop looping */
            break;
        }
		if (ret == SQLITE_ROW)
        {
            /* ok, we've just fetched a valid row to process */
            row_no++;
            printf ("row #%d\n", row_no);
            
            AGSGeometry* geometry;
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for (ic = 0; ic < n_columns; ic++)
			{
                /*
                 and now we'll fetch column values
                 
                 for each column we'll then get:
                 - the column name
                 - a column value, that can be of type: SQLITE_NULL, SQLITE_INTEGER,
                 SQLITE_FLOAT, SQLITE_TEXT or SQLITE_BLOB, according to internal DB storage type
                 */
			    printf ("\t%-10s = ",
                        sqlite3_column_name (stmt, ic));
                
                NSString *key = [NSString stringWithFormat:@"%s",sqlite3_column_name (stmt, ic)];
                NSString *value;
			    switch (sqlite3_column_type (stmt, ic))
                {
                    case SQLITE_NULL:
                        printf ("NULL");
                        break;
                    case SQLITE_INTEGER:
                        printf ("%d", sqlite3_column_int (stmt, ic));
                        value = [NSString stringWithFormat:@"%d",sqlite3_column_int (stmt, ic)];
                        
                        if (value != nil) {
                            [dict setObject:value forKey:key];
                        }
                        break;
                    case SQLITE_FLOAT:
                        printf ("%1.4f",
                                sqlite3_column_double (stmt, ic));
                        value = [NSString stringWithFormat:@"%f",sqlite3_column_double (stmt, ic)];
                        if (value != nil) {
                            [dict setObject:value forKey:key];
                        }
                        break;
                    case SQLITE_TEXT:
                        printf ("'%s'",
                                sqlite3_column_text (stmt, ic));
                        value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text (stmt, ic)];
                        if (value != nil) {
                            [dict setObject:value forKey:key];
                        }
                        break;
                    case SQLITE_BLOB:
                        blob = (unsigned char *)sqlite3_column_blob (stmt, ic);
                        blob_size = sqlite3_column_bytes (stmt, ic);
                        
                        /* checking if this BLOB actually is a GEOMETRY */
                        geom =
                        gaiaFromSpatiaLiteBlobWkb (blob,
                                                   blob_size);
                        if (!geom)
                        {
                            /* for sure this one is not a GEOMETRY */
                            printf ("BLOB [%d bytes]", blob_size);
                        }
                        else
                        {
                            
                            geom_type = gaiaGeometryType (geom);
                            if (geom_type == GAIA_UNKNOWN)
                                printf ("EMPTY or NULL GEOMETRY");
                            else
                            {
                                char *geom_name;
                                if (geom_type == GAIA_POINT)
                                {
                                    geom_name = "POINT";

                                    geometry = [[AGSPoint alloc] initWithX:geom->FirstPoint->X y:geom->FirstPoint->Y spatialReference:nil];
                                }
                                if (geom_type == GAIA_LINESTRING)
                                {
                                    geom_name = "LINESTRING";
                                    AGSMutablePolyline *line = [[AGSMutablePolyline alloc] init];
                                    gaiaLinestringPtr lineprt = geom->FirstLinestring;
                                    [line addPathToPolyline];
                                    for (int i=0; i<lineprt->Points; i++) {
                                        double x,y;
                                        gaiaGetPoint(lineprt->Coords,i,&x,&y);
                                        AGSPoint *point = [[AGSPoint alloc] initWithX:x y:y spatialReference:nil];
                                        //[line addPoint:point toPath:0];
                                        [line addPointToPath:point];
                                    }
                                    geometry = line;
                                }
                                if (geom_type == GAIA_POLYGON)
                                {
                                    geom_name = "POLYGON";
                                    AGSMutablePolygon *polyon = [[AGSMutablePolygon alloc] init];
                                    [polyon addRingToPolygon];
                                    gaiaPolygonPtr polygonprt = geom->FirstPolygon;
                                    for (int i=0; i<polygonprt->Exterior->Points; i++) {
                                        double x,y;
                                        gaiaGetPoint(polygonprt->Exterior->Coords,i,&x,&y);
                                        AGSPoint *point = [[AGSPoint alloc] initWithX:x y:y spatialReference:nil];
                                        //[line addPoint:point toPath:0];
                                        [polyon addPointToRing:point];
                                    }
                                    geometry = polyon;
                                }
                                if (geom_type == GAIA_MULTIPOINT)
                                    geom_name = "MULTIPOINT";
                                if (geom_type ==
                                    GAIA_MULTILINESTRING)
                                    geom_name = "MULTILINESTRING";
                                if (geom_type ==
                                    GAIA_MULTIPOLYGON)
                                    geom_name = "MULTIPOLYGON";
                                if (geom_type ==
                                    GAIA_GEOMETRYCOLLECTION)
                                    geom_name =
                                    "GEOMETRYCOLLECTION";
                                printf ("%s SRID=%d", geom_name,
                                        geom->Srid);
                                if (geom_type == GAIA_LINESTRING
                                    || geom_type ==
                                    GAIA_MULTILINESTRING)
                                {
//#ifndef OMIT_GEOS		/* GEOS is required */
//                                    gaiaGeomCollLength (geom,
//                                                        &measure);
//                                    printf (" length=%1.2f",
//                                            measure);
//#else
//                                    printf
//                                    (" length=?? [no GEOS support available]");
//#endif /* GEOS enabled/disabled */
                                }
                                if (geom_type == GAIA_POLYGON ||
                                    geom_type ==
                                    GAIA_MULTIPOLYGON)
                                {
//#ifndef OMIT_GEOS		/* GEOS is required */
//                                    gaiaGeomCollArea (geom,
//                                                      &measure);
//                                    printf (" area=%1.2f",
//                                            measure);
//#else
//                                    printf
//                                    ("area=?? [no GEOS support available]");
//#endif /* GEOS enabled/disabled */
                                }
                                

                            }
                            /* we have now to free the GEOMETRY */
                            gaiaFreeGeomColl (geom);
                        }
                        
                        break;
                };
			    printf ("\n");
   
                
			}
            
            AGSGraphic*graphic = [AGSGraphic graphicWithGeometry:geometry symbol:symbol attributes:dict];
            [graphicsLayer addGraphic:graphic];
            [graphicsLayer refresh];
            
//            if (row_no >= 5)
//			{
//                /* we'll exit the loop after the first 5 rows - this is only a demo :-) */
//			    break;
//			}
        }
		else
        {
            /* some unexpected error occurred */
            printf ("sqlite3_step() error: %s\n",
                    sqlite3_errmsg (_handle));
            sqlite3_finalize (stmt);
            return FALSE;
        }
    }
    /* we have now to finalize the query [memory cleanup] */
    sqlite3_finalize (stmt);
    
    
    return TRUE;
}

- (BOOL) createPhotoLayer:(NSString *)path
{
    int ret = 0;
    char *err_msg = NULL;
    char sql[256];
    /*
     now we can create the test table
     for simplicity we'll define only one column, the primary key
     */
    strcpy (sql, "CREATE TABLE ");
    strcat (sql, "Photo");
    strcat (sql, " (");
    strcat (sql, "id INTEGER NOT NULL PRIMARY KEY)");
    ret = sqlite3_exec (_handle, sql, NULL, NULL, &err_msg);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("CREATE TABLE 'Photo' error: %s\n", err_msg);
        sqlite3_free (err_msg);
        return FALSE;
    }
    
    
    /*
     ... we'll add a Geometry column of POINT type to the test table
     */
    strcpy (sql, "SELECT AddGeometryColumn('");
    strcat (sql, "Photo");
    strcat (sql, "', 'geom', 4326, 'POINT', 2)");

    
    ret = sqlite3_exec (_handle, sql, NULL, NULL, &err_msg);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("AddGeometryColumn() error: %s\n", err_msg);
        sqlite3_free (err_msg);
        return FALSE;
    }
    
    strcpy (sql, "alter TABLE Photo add filename varchar ( 256 )");
    ret = sqlite3_exec (_handle, sql, NULL, NULL, &err_msg);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("alter error: %s\n", err_msg);
        sqlite3_free (err_msg);
        return FALSE;
    }
            
    /*
     and finally we'll enable this geo-column to have a Spatial Index based on R*Tree
     */
    strcpy (sql, "SELECT CreateSpatialIndex('");
    strcat (sql, "Photo");
    strcat (sql, "', 'geom')");
    ret = sqlite3_exec (_handle, sql, NULL, NULL, &err_msg);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("CreateSpatialIndex() error: %s\n", err_msg);
        sqlite3_free (err_msg);
        return FALSE;
    }
    
    
    // 照片目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *photoDir = [path stringByAppendingPathComponent:@"Photo"];
    [fileManager createDirectoryAtPath:photoDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    return TRUE;
}

- (BOOL) openPhotoLayer:(NSString *)path
{
    // 照片目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *photoDir = [path stringByAppendingPathComponent:@"Photo"];
    if(![fileManager fileExistsAtPath:photoDir])
    {
        [fileManager createDirectoryAtPath:photoDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return TRUE;
}

-(BOOL) createGPSLayer:(NSString *)path
{
    GPSLayer *gpsLayer= [[GPSLayer alloc] init];
    [self.mapView addMapLayer:gpsLayer withName:@"GPS layer"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *gpsDir = [path stringByAppendingPathComponent:@"Track"];
    [fileManager createDirectoryAtPath:gpsDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    return TRUE;
}

-(BOOL) openGPSLayer:(NSString *)path
{
    GPSLayer *gpsLayer= [[GPSLayer alloc] init];
    [self.mapView addMapLayer:gpsLayer withName:@"GPS layer"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *gpsDir = [path stringByAppendingPathComponent:@"Track"];
    if(![fileManager fileExistsAtPath:gpsDir])
    {
        [fileManager createDirectoryAtPath:gpsDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return TRUE;
}

-(BOOL) createBaseLayer
{
    //Add a basemap tiled layer
    NSURL* url = [NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer"];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [self.mapView addMapLayer:tiledLayer withName:@"Basemap Tiled Layer"];
    
    EditLayer *sketchLayer= [[EditLayer alloc] initWithGeometry:nil];
    [self.mapView addMapLayer:sketchLayer withName:@"Sketch layer"];
    
    MeasureLayer *measureLayer= [[MeasureLayer alloc] init];
    [self.mapView addMapLayer:measureLayer withName:@"Measure layer"];

    
    return TRUE;
}

-(BOOL) open:(NSString *)path
{
    NSString *dataPath = [path stringByAppendingPathComponent:@"data.db"];
    
    //    test11(dataPath.UTF8String);
    
    int ret = sqlite3_open_v2 (dataPath.UTF8String, &_handle,
                               SQLITE_OPEN_READWRITE, NULL);
    if (ret != SQLITE_OK)
    {
        sqlite3_close (_handle);
        return FALSE;
    }
    //    void *cache = spatialite_alloc_connection ();
    //    spatialite_init_ex (_handle, cache, 0);
    spatialite_init(0);
    
    /* showing the SQLite version */
    printf ("SQLite version: %s\n", sqlite3_libversion ());
    /* showing the SpatiaLite version */
    printf ("SpatiaLite version: %s\n", spatialite_version ());
    printf ("\n\n");
    
    [self createBaseLayer];
    [self openGPSLayer:path];
    [self openLayer:@"Region" type:AGSGeometryTypePolygon];
    [self openLayer:@"Line" type:AGSGeometryTypePolyline];
    [self openLayer:@"Point" type:AGSGeometryTypePoint];
    
    [self openPhotoLayer:path];
    
    self.path = path;
    
    NSLog(@"project path %@", self.path);
    return TRUE;
}
-(BOOL) close
{
    [self.mapView reset];
    
    if (_handle != NULL) {
        sqlite3_close (_handle);
        _handle = NULL;
    }
    return TRUE;
}

-(NSMutableArray*) allFieldInfo:(AGSGeometryType)geometryType
{
    int ret = 0;
    char *err_msg = NULL;
    char sql[256];
    
    NSString *layername;
    
    AGSSymbol *symbol;
    if (geometryType == AGSGeometryTypePoint) {
        
        layername = @"Point";
    }
    else if(geometryType == AGSGeometryTypePolyline)
    {
        layername = @"Line";
    }
    else if(geometryType == AGSGeometryTypePolygon)
    {
        layername = @"Region";
    }
    
    strcpy (sql, "select * from ");
    strcat (sql, layername.UTF8String);
    strcat (sql, " where 0=1");
    
    sqlite3_stmt *stmt = NULL;
    const char *tail=NULL;
    int ret_code = sqlite3_prepare_v2(_handle, sql, -1, &stmt, &tail);
    if(ret_code!=SQLITE_OK)
    {
        if(stmt)
            sqlite3_finalize(stmt);
        return nil;
    }
    
    NSMutableArray *fieldInfos = [[NSMutableArray alloc] init];
    
    int col_count = sqlite3_column_count(stmt);
    
    for(int col=0;col<col_count;col++)
    {
        FieldInfo *fieldInfo = [[FieldInfo alloc] init];
        int coldatatype = sqlite3_column_type(stmt, col);
    
        const char* colname = sqlite3_column_name(stmt, col);
        
        //int col_size = sqlite3_column_bytes(m_stmt, col);
        
        if(strcmp(colname, "geom") == 0)
        {
            continue;
        }
        fieldInfo.type = coldatatype;
        fieldInfo.name = [NSString stringWithUTF8String:colname];
        
        [fieldInfos addObject:fieldInfo];
    }
    
    
    if(stmt)
        sqlite3_finalize(stmt);
    
    return fieldInfos;
}

-(BOOL) addGeometry:(AGSGeometry*)geometry
{
    int ret = 0;
    char *err_msg = NULL;
    char sql[256];
    
    sqlite3_stmt *stmt;
    
    gaiaGeomCollPtr geo = NULL;
    unsigned char *blob;
    int blob_size;
    

    
    /* preparing the geometry to insert */
    geo = gaiaAllocGeomColl ();
    geo->Srid = 4326;

    AGSGeometryType geometryType = AGSGeometryTypeForGeometry(geometry);
    
    NSString *layername;
    
    AGSSymbol *symbol;
    if (geometryType == AGSGeometryTypePoint) {
        
        layername = @"Point";
        
        AGSSimpleMarkerSymbol* myMarkerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
        myMarkerSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        
        symbol = myMarkerSymbol;
        
        //geometry
        AGSPoint *point = (AGSPoint *)geometry;
        gaiaAddPointToGeomColl (geo, point.x, point.y);
    }
    else if(geometryType == AGSGeometryTypePolyline)
    {
        layername = @"Line";
        AGSSimpleFillSymbol* myFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        myFillSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        //线的边框还是“线”
        AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
        myOutlineSymbol.color = [UIColor redColor];
        myOutlineSymbol.width = 2;
        //set the outline property to myOutlineSymbol
        myFillSymbol.outline = myOutlineSymbol;
        
        symbol = myFillSymbol;
        
        AGSPolyline *line = (AGSPolyline *)geometry;
        gaiaLinestringPtr lineprt;
        lineprt = gaiaAddLinestringToGeomColl (geo, line.numPoints);
        for(int i =0;i<line.numPoints;i++)
        {
            AGSPoint * point = [line pointOnPath:0 atIndex:i];
            gaiaSetPoint (lineprt->Coords, i, point.x, point.y);
        }
    }
    else if(geometryType == AGSGeometryTypePolygon)
    {
        layername = @"Region";
        AGSSimpleFillSymbol* myFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        myFillSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        //线的边框还是“线”
        AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
        myOutlineSymbol.color = [UIColor redColor];
        myOutlineSymbol.width = 2;
        //set the outline property to myOutlineSymbol
        myFillSymbol.outline = myOutlineSymbol;
        
        symbol = myFillSymbol;
        
        AGSPolygon *polygon = (AGSPolygon *)geometry;
        gaiaPolygonPtr polygonptr;
        polygonptr = gaiaAddPolygonToGeomColl (geo, polygon.numPoints,0);
        for(int i =0;i<polygon.numPoints;i++)
        {
            AGSPoint * point = [polygon pointOnRing:0 atIndex:i];
            gaiaSetPoint (polygonptr->Exterior->Coords, i, point.x, point.y);
        }
    }
    
    strcpy (sql, "INSERT INTO ");
    strcat (sql, layername.UTF8String);
    strcat (sql, " (id, geom) VALUES (?, ?)");
    ret = sqlite3_prepare_v2 (_handle, sql, strlen (sql), &stmt, NULL);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("INSERT SQL error: %s\n", sqlite3_errmsg (_handle));
        return FALSE;
    }
    
    
    /* transforming this geometry into the SpatiaLite BLOB format */
    gaiaToSpatiaLiteBlobWkb (geo, &blob, &blob_size);
    
    /* we can now destroy the geometry object */
    gaiaFreeGeomColl (geo);
    
    /* resetting Prepared Statement and bindings */
    sqlite3_reset (stmt);
    sqlite3_clear_bindings (stmt);
    
    /* binding parameters to Prepared Statement */
    //sqlite3_bind_int64 (stmt, 1, pk);
    sqlite3_bind_blob (stmt, 2, blob, blob_size, free);
    
    /* performing actual row insert */
    ret = sqlite3_step (stmt);
    if (ret == SQLITE_DONE || ret == SQLITE_ROW)
        ;
    else
    {
        /* an unexpected error occurred */
        printf ("sqlite3_step() error: %s\n",
                sqlite3_errmsg (_handle));
        sqlite3_finalize (stmt);
        return FALSE;
    }
    
    /* we have now to finalize the query [memory cleanup] */
    sqlite3_finalize (stmt);    
    

    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[self.mapView mapLayerForName:layername];
    
    

    
    
    AGSGraphic*graphic = [AGSGraphic graphicWithGeometry:geometry symbol:symbol attributes:nil];
    [graphicsLayer addGraphic:graphic];
    [graphicsLayer refresh];
    return TRUE;
}

-(BOOL) addGraphic:(AGSGraphic*)graphic
{
    int ret = 0;
    char *err_msg = NULL;
    char sql[256];
    
    sqlite3_stmt *stmt;
    
    gaiaGeomCollPtr geo = NULL;
    unsigned char *blob;
    int blob_size;
    
    
    
    /* preparing the geometry to insert */
    geo = gaiaAllocGeomColl ();
    geo->Srid = 4326;
    
    AGSGeometryType geometryType = AGSGeometryTypeForGeometry(graphic.geometry);
    
    NSString *layername;
    
    AGSSymbol *symbol;
    if (geometryType == AGSGeometryTypePoint) {
        
        layername = @"Point";
        
        AGSSimpleMarkerSymbol* myMarkerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
        myMarkerSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        
        symbol = myMarkerSymbol;
        
        //geometry
        AGSPoint *point = (AGSPoint *)graphic.geometry;
        gaiaAddPointToGeomColl (geo, point.x, point.y);
    }
    else if(geometryType == AGSGeometryTypePolyline)
    {
        layername = @"Line";
        AGSSimpleFillSymbol* myFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        myFillSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        //线的边框还是“线”
        AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
        myOutlineSymbol.color = [UIColor redColor];
        myOutlineSymbol.width = 2;
        //set the outline property to myOutlineSymbol
        myFillSymbol.outline = myOutlineSymbol;
        
        symbol = myFillSymbol;
        
        AGSPolyline *line = (AGSPolyline *)graphic.geometry;
        gaiaLinestringPtr lineprt;
        lineprt = gaiaAddLinestringToGeomColl (geo, line.numPoints);
        for(int i =0;i<line.numPoints;i++)
        {
            AGSPoint * point = [line pointOnPath:0 atIndex:i];
            gaiaSetPoint (lineprt->Coords, i, point.x, point.y);
        }
    }
    else if(geometryType == AGSGeometryTypePolygon)
    {
        layername = @"Region";
        AGSSimpleFillSymbol* myFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        myFillSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        //线的边框还是“线”
        AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
        myOutlineSymbol.color = [UIColor redColor];
        myOutlineSymbol.width = 2;
        //set the outline property to myOutlineSymbol
        myFillSymbol.outline = myOutlineSymbol;
        
        symbol = myFillSymbol;
        
        AGSPolygon *polygon = (AGSPolygon *)graphic.geometry;
        gaiaPolygonPtr polygonptr;
        polygonptr = gaiaAddPolygonToGeomColl (geo, polygon.numPoints,0);
        for(int i =0;i<polygon.numPoints;i++)
        {
            AGSPoint * point = [polygon pointOnRing:0 atIndex:i];
            gaiaSetPoint (polygonptr->Exterior->Coords, i, point.x, point.y);
        }
    }
    

    
    
    strcpy (sql, "INSERT INTO ");
    strcat (sql, layername.UTF8String);
    //strcat (sql, " (id, geom) VALUES (?, ?)");
    
    NSString *fieldname = @"id, geom";
    NSString *fieldvalue = @"?,?";
    for (id key in [graphic.allAttributes allKeys]) {
        //NSLog(@"Key:%@,Value:%@",key,[graphic.allAttributes objectForKey:key]);
        fieldname = [fieldname stringByAppendingFormat:@",%@",key];
        fieldvalue = [fieldvalue stringByAppendingString:@",?"];
    
    }
    
    strcat(sql, " (");
    strcat (sql, fieldname.UTF8String);
    strcat(sql, ") VALUES (");
    strcat (sql, fieldvalue.UTF8String);
    strcat(sql, ")");
    
    
    ret = sqlite3_prepare_v2 (_handle, sql, strlen (sql), &stmt, NULL);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("INSERT SQL error: %s\n", sqlite3_errmsg (_handle));
        return FALSE;
    }
    
    
    /* transforming this geometry into the SpatiaLite BLOB format */
    gaiaToSpatiaLiteBlobWkb (geo, &blob, &blob_size);
    
    /* we can now destroy the geometry object */
    gaiaFreeGeomColl (geo);
    
    /* resetting Prepared Statement and bindings */
    sqlite3_reset (stmt);
    sqlite3_clear_bindings (stmt);
    
    /* binding parameters to Prepared Statement */
    //sqlite3_bind_int64 (stmt, 1, pk);
    sqlite3_bind_blob (stmt, 2, blob, blob_size, free);
    
    int index = 3;
    for (id key in [graphic.allAttributes allKeys])
    {
        NSString *value = [graphic.allAttributes objectForKey:key];
        
        const char *pData = value.UTF8String;
        sqlite3_bind_text (stmt, index, pData,strlen(pData), SQLITE_STATIC);
        
        index ++;
    }
    /* performing actual row insert */
    ret = sqlite3_step (stmt);
    if (ret == SQLITE_DONE || ret == SQLITE_ROW)
        ;
    else
    {
        /* an unexpected error occurred */
        printf ("sqlite3_step() error: %s\n",
                sqlite3_errmsg (_handle));
        sqlite3_finalize (stmt);
        return FALSE;
    }
    
    /* we have now to finalize the query [memory cleanup] */
    sqlite3_finalize (stmt);
    
    
    graphic.symbol = symbol;
    
    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[self.mapView mapLayerForName:layername];
    
    
    
    [graphicsLayer addGraphic:graphic];
    [graphicsLayer refresh];
    
    return true;
}

-(BOOL) saveGraphic:(AGSGraphic*)graphic
{
    int ret = 0;
    char *err_msg = NULL;
    char sql[256];
    
    sqlite3_stmt *stmt;
    
    gaiaGeomCollPtr geo = NULL;
    unsigned char *blob;
    int blob_size;
    
    
    
    /* preparing the geometry to insert */
    geo = gaiaAllocGeomColl ();
    geo->Srid = 4326;
    
    AGSGeometryType geometryType = AGSGeometryTypeForGeometry(graphic.geometry);
    
    NSString *layername;
    
    AGSSymbol *symbol;
    if (geometryType == AGSGeometryTypePoint) {
        
        layername = @"Point";
        
        AGSSimpleMarkerSymbol* myMarkerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
        myMarkerSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        
        symbol = myMarkerSymbol;
        
        //geometry
        AGSPoint *point = (AGSPoint *)graphic.geometry;
        gaiaAddPointToGeomColl (geo, point.x, point.y);
    }
    else if(geometryType == AGSGeometryTypePolyline)
    {
        layername = @"Line";
        AGSSimpleFillSymbol* myFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        myFillSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        //线的边框还是“线”
        AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
        myOutlineSymbol.color = [UIColor redColor];
        myOutlineSymbol.width = 2;
        //set the outline property to myOutlineSymbol
        myFillSymbol.outline = myOutlineSymbol;
        
        symbol = myFillSymbol;
        
        AGSPolyline *line = (AGSPolyline *)graphic.geometry;
        gaiaLinestringPtr lineprt;
        lineprt = gaiaAddLinestringToGeomColl (geo, line.numPoints);
        for(int i =0;i<line.numPoints;i++)
        {
            AGSPoint * point = [line pointOnPath:0 atIndex:i];
            gaiaSetPoint (lineprt->Coords, i, point.x, point.y);
        }
    }
    else if(geometryType == AGSGeometryTypePolygon)
    {
        layername = @"Region";
        AGSSimpleFillSymbol* myFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        myFillSymbol.color = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.5];
        //线的边框还是“线”
        AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
        myOutlineSymbol.color = [UIColor redColor];
        myOutlineSymbol.width = 2;
        //set the outline property to myOutlineSymbol
        myFillSymbol.outline = myOutlineSymbol;
        
        symbol = myFillSymbol;
        
        AGSPolygon *polygon = (AGSPolygon *)graphic.geometry;
        gaiaPolygonPtr polygonptr;
        polygonptr = gaiaAddPolygonToGeomColl (geo, polygon.numPoints,0);
        for(int i =0;i<polygon.numPoints;i++)
        {
            AGSPoint * point = [polygon pointOnRing:0 atIndex:i];
            gaiaSetPoint (polygonptr->Exterior->Coords, i, point.x, point.y);
        }
    }
    
    
    
    //UPDATE Person SET Address = 'Zhongshan 23', City = 'Nanjing' WHERE LastName = 'Wilson'
    strcpy (sql, "UPDATE ");
    strcat (sql, layername.UTF8String);
    strcat (sql, " SET geom = ?,");
    

    for (id key in [graphic.allAttributes allKeys]) {
        //NSLog(@"Key:%@,Value:%@",key,[graphic.allAttributes objectForKey:key]);
        //fieldname = [fieldname stringByAppendingFormat:@",%@",key];
        //fieldvalue = [fieldvalue stringByAppendingString:@",?"];
        
        strcat(sql, [NSString stringWithFormat:@"%@",key].UTF8String);
        strcat(sql, " = ?,");
    }
    sql[strlen(sql)-1] = '\0';
    
    strcat(sql, " WHERE id = ");
    char szid[256];
    int gid = [graphic attributeAsIntForKey:@"id" exists:nil];
    sprintf(szid,"%d",gid);
    strcat(sql, szid);
    
    ret = sqlite3_prepare_v2 (_handle, sql, strlen (sql), &stmt, NULL);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("INSERT SQL error: %s\n", sqlite3_errmsg (_handle));
        return FALSE;
    }
    
    
    /* transforming this geometry into the SpatiaLite BLOB format */
    gaiaToSpatiaLiteBlobWkb (geo, &blob, &blob_size);
    
    /* we can now destroy the geometry object */
    gaiaFreeGeomColl (geo);
    
    /* resetting Prepared Statement and bindings */
    sqlite3_reset (stmt);
    sqlite3_clear_bindings (stmt);
    
    /* binding parameters to Prepared Statement */
    sqlite3_bind_blob (stmt, 1, blob, blob_size, free);
    
    int index = 2;
    for (id key in [graphic.allAttributes allKeys])
    {
        NSString *value = [graphic.allAttributes objectForKey:key];
        const char *pData = value.UTF8String;
        sqlite3_bind_text (stmt, index, pData,strlen(pData), SQLITE_STATIC);
        index ++;
    }
    /* performing actual row insert */
    ret = sqlite3_step (stmt);
    if (ret == SQLITE_DONE || ret == SQLITE_ROW)
        ;
    else
    {
        /* an unexpected error occurred */
        printf ("sqlite3_step() error: %s\n",
                sqlite3_errmsg (_handle));
        sqlite3_finalize (stmt);
        return FALSE;
    }
    
    /* we have now to finalize the query [memory cleanup] */
    sqlite3_finalize (stmt);
    
    
//    graphic.symbol = symbol;
//    
//    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[self.mapView mapLayerForName:layername];
//    
//    
//    
//    [graphicsLayer addGraphic:graphic];
//    [graphicsLayer refresh];
    return TRUE;
}

-(BOOL) removeGraphic:(AGSGraphic*)graphic
{
    AGSGeometryType geometryType = AGSGeometryTypeForGeometry(graphic.geometry);
    
    NSString *layername;
    
    AGSSymbol *symbol;
    if (geometryType == AGSGeometryTypePoint) {
        layername = @"Point";
    }
    else if(geometryType == AGSGeometryTypePolyline)
    {
        layername = @"Line";
    }
    else if(geometryType == AGSGeometryTypePolygon)
    {
        layername = @"Region";
    }
    
    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[self.mapView mapLayerForName:layername];
    
    
    
    [graphicsLayer removeGraphic:graphic];
    [graphicsLayer refresh];
    
    char *err_msg = NULL;
    char sql[256];
    strcpy (sql, "DELETE FROM ");
    strcat (sql, layername.UTF8String);
    strcat (sql, " WHERE id = ");
    char szid[256];
    int gid = [graphic attributeAsIntForKey:@"id" exists:nil];
    sprintf(szid,"%d",gid);
    
    strcat (sql, szid);
    
    int ret = sqlite3_exec (_handle, sql, NULL, NULL, &err_msg);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("delete error: %s\n", err_msg);
        sqlite3_free (err_msg);
        return FALSE;
    }
    
    return TRUE;
}

-(NSString *) addPhoto:(Photo*)photo
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSString *shortFileName = [formatter stringFromDate:date];
    
    NSString *photoDir = [path stringByAppendingPathComponent:@"Photo"];
    NSString *photoFilePath = [photoDir stringByAppendingPathComponent:shortFileName];
    NSString *fileName = [photoFilePath stringByAppendingPathExtension:@"jpg"];
    
    NSData *imageData = UIImageJPEGRepresentation(photo.image, 0.8);
    
    if(![imageData writeToFile:fileName atomically:YES])
    {
        return nil;
    }
    
    int ret = 0;
    char *err_msg = NULL;
    char sql[256];
    
    sqlite3_stmt *stmt;
    
    gaiaGeomCollPtr geo = NULL;
    unsigned char *blob;
    int blob_size;
    
    
    
    /* preparing the geometry to insert */
    geo = gaiaAllocGeomColl ();
    geo->Srid = 4326;
    
    gaiaAddPointToGeomColl (geo, photo.point.x, photo.point.y);
    
    strcpy (sql, "INSERT INTO ");
    strcat (sql, "Photo");
    strcat (sql, " (id, geom, filename) VALUES (?, ?, ?)");
    ret = sqlite3_prepare_v2 (_handle, sql, strlen (sql), &stmt, NULL);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("INSERT SQL error: %s\n", sqlite3_errmsg (_handle));
        return FALSE;
    }
    
    
    /* transforming this geometry into the SpatiaLite BLOB format */
    gaiaToSpatiaLiteBlobWkb (geo, &blob, &blob_size);
    
    /* we can now destroy the geometry object */
    gaiaFreeGeomColl (geo);
    
    /* resetting Prepared Statement and bindings */
    sqlite3_reset (stmt);
    sqlite3_clear_bindings (stmt);
    
    /* binding parameters to Prepared Statement */
    //sqlite3_bind_int64 (stmt, 1, pk);
    sqlite3_bind_blob (stmt, 2, blob, blob_size, free);
    sqlite3_bind_text (stmt, 3, shortFileName.UTF8String, shortFileName.length,SQLITE_STATIC);
    
    /* performing actual row insert */
    ret = sqlite3_step (stmt);
    if (ret == SQLITE_DONE || ret == SQLITE_ROW)
        ;
    else
    {
        /* an unexpected error occurred */
        printf ("sqlite3_step() error: %s\n",
                sqlite3_errmsg (_handle));
        sqlite3_finalize (stmt);
        return nil;
    }
    
    /* we have now to finalize the query [memory cleanup] */
    sqlite3_finalize (stmt);
    
    return shortFileName;
}

-(NSMutableArray*) search:(NSString *)key
{

    
    return nil;
}

-(NSInteger) photoCount
{
    int ret = 0;
    char *err_msg = NULL;
    char sql[256];
    
    sqlite3_stmt *stmt;
    
    strcpy (sql, "select count(*) from Photo");
    ret = sqlite3_prepare_v2 (_handle, sql, strlen (sql), &stmt, NULL);
    if (ret != SQLITE_OK)
    {
        /* an error occurred */
        printf ("INSERT SQL error: %s\n", sqlite3_errmsg (_handle));
        return 0;
    }
    
    ret = sqlite3_step (stmt);
    if (ret != SQLITE_ROW)
    {
        return 0;
    }
    
    return sqlite3_column_int (stmt, 0);
}

-(NSMutableArray*) allPhoto
{
    int ret = 0;
    char *err_msg = NULL;
    char sql[256];
    
    sqlite3_stmt *stmt;
    
    gaiaGeomCollPtr geom;
    int ic;
    int n_rows;
    int n_columns;
    int row_no;
    const unsigned char *blob;
    int blob_size;
    int geom_type;
    
    strcpy (sql, "SELECT geom, filename FROM Photo");
    
    ret = sqlite3_prepare_v2 (_handle, sql, strlen (sql), &stmt, NULL);
    if (ret != SQLITE_OK)
    {
        /* some error occurred */
		printf ("query#2 SQL error: %s\n", sqlite3_errmsg (_handle));
		return nil;
    }
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    while (1)
    {
        /* this is an infinite loop, intended to fetch any row */
        
        /* we are now trying to fetch the next available row */
		ret = sqlite3_step (stmt);
		if (ret == SQLITE_DONE)
        {
            /* there are no more rows to fetch - we can stop looping */
            break;
        }
		if (ret == SQLITE_ROW)
        {
            /* ok, we've just fetched a valid row to process */
            row_no++;
            printf ("row #%d\n", row_no);
            
            Photo * photo = [[Photo alloc] init];
            
            blob = (unsigned char *)sqlite3_column_blob (stmt, 0);
            blob_size = sqlite3_column_bytes (stmt, 0);
            
            /* checking if this BLOB actually is a GEOMETRY */
            geom =
            gaiaFromSpatiaLiteBlobWkb (blob,
                                       blob_size);
            if (!geom)
            {
                /* for sure this one is not a GEOMETRY */
                printf ("BLOB [%d bytes]", blob_size);
            }
            else
            {
                AGSGeometry* geometry;
                geom_type = gaiaGeometryType (geom);
                if (geom_type == GAIA_UNKNOWN)
                    printf ("EMPTY or NULL GEOMETRY");
                else
                {
                    if (geom_type == GAIA_POINT)
                    {

                        photo.point = [[AGSPoint alloc] initWithX:geom->FirstPoint->X y:geom->FirstPoint->Y spatialReference:nil];
                    }
                }
            }

            
            const char *pFileName = (const char *)sqlite3_column_text (stmt, 1);
            photo.fileName = [NSString stringWithUTF8String:pFileName];
      
            NSString *photoDir = [path stringByAppendingPathComponent:@"Photo"];
            NSString *photoFilePath = [photoDir stringByAppendingPathComponent:photo.fileName];
            NSString *fileName = [photoFilePath stringByAppendingPathExtension:@"jpg"];
            
            photo.image = [UIImage imageWithContentsOfFile: fileName];
            
            [photos addObject:photo];
        }
		else
        {
            /* some unexpected error occurred */
            printf ("sqlite3_step() error: %s\n",
                    sqlite3_errmsg (_handle));
            sqlite3_finalize (stmt);
            return nil;
        }
    }
    /* we have now to finalize the query [memory cleanup] */
    sqlite3_finalize (stmt);
    
    return photos;
}

-(BOOL) saveTrack:(NSString *)gpx Name:(NSString *)name
{
    NSString *gpsDir = [path stringByAppendingPathComponent:@"Track"];
    NSString *gpxFilePath = [gpsDir stringByAppendingPathComponent:name];
    NSString *fileName = [gpxFilePath stringByAppendingPathExtension:@"gpx"];
    
    NSError *error;
    if (![gpx writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        if (error) {
            NSLog(@"error, %@", error);
        }
        
        return FALSE;
    }
    return TRUE;
}

@end
