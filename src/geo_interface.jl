# TODO add back constructors for geometries using the GeoInterface

GeoInterfaceRFC.geomtype(g::Point) = GeoInterfaceRFC.Point()
GeoInterfaceRFC.geomtype(g::LineString) = GeoInterfaceRFC.LineString()
GeoInterfaceRFC.geomtype(g::Polygon) = GeoInterfaceRFC.Polygon()
GeoInterfaceRFC.geomtype(g::MultiPoint) = GeoInterfaceRFC.MultiPoint()
GeoInterfaceRFC.geomtype(g::MultiLineString) = GeoInterfaceRFC.MultiLineString()
GeoInterfaceRFC.geomtype(g::MultiPolygon) = GeoInterfaceRFC.MultiPolygon()
GeoInterfaceRFC.geomtype(g::GeometryCollection) = GeoInterfaceRFC.GeometryCollection()
GeoInterfaceRFC.geomtype(g::LinearRing) = GeoInterfaceRFC.LineString()


function GeoInterfaceRFC.ncoord(g::Geometry)
    cs = getCoordSeq(g.ptr)
    getDimensions(cs)
end

function GeoInterfaceRFC.getcoord(g::Point, i::Int)
    cs = getCoordSeq(g.ptr)
    if i == 1
        getX(cs, 1)
    elseif i == 2
        getY(cs, 1)
    elseif i == 3
        getZ(cs, 1)
    else
        throw(ArgumentError("GEOS only supports 2 and 3 dimensional points"))
    end
end

function GeoInterfaceRFC.npoint(g::LineString)
    numPoints(g)
end

function GeoInterfaceRFC.getpoint(g::LineString, i::Int)
    cs = getCoordSeq(g.ptr)
    nc = getDimensions(cs)
    np = getSize(cs)
    if i > np || i < 1
        # otherwise we get garbage back
        throw(BoundsError(cs, i))
    end
    x = LibGEOS.getX(cs, i)
    y = LibGEOS.getY(cs, i)
    if nc == 2
        Point(x, y)
    else
        z = LibGEOS.getZ(cs, i)
        Point(x, y, z)
    end
end

GeoInterfaceRFC.isclosed(g::LineString) = isClosed(g)

GeoInterfaceRFC.getexterior(g::Polygon) = exteriorRing(g)
GeoInterfaceRFC.nhole(g::Polygon) = numInteriorRings(g.ptr)
GeoInterfaceRFC.gethole(g::Polygon, i::Int) = interiorRing(g.ptr, i)

GeoInterfaceRFC.npoint(g::MultiPoint) = getDimensions(g.ptr)
GeoInterfaceRFC.nlinestring(g::MultiLineString) = getDimensions(g.ptr)
GeoInterfaceRFC.npolygon(g::MultiPolygon) = getDimensions(g.ptr)
GeoInterfaceRFC.ngeom(g::GeometryCollection) = getDimensions(g.ptr)

function GeoInterfaceRFC.getpoint(g::MultiPoint, i::Int)
    ptr = LibGEOS.getGeometry(g.ptr, i)
    Point(ptr)
end

function GeoInterfaceRFC.getlinestring(g::MultiLineString, i::Int)
    ptr = getGeometry(g.ptr, i)
    LineString(ptr)
end

function GeoInterfaceRFC.getpolygon(g::MultiPolygon, i::Int)
    ptr = getGeometry(g.ptr, i)
    Polygon(ptr)
end

function GeoInterfaceRFC.getgeom(g::GeometryCollection, i::Int)
    ptr = getGeometry(g.ptr, i)
    geomFromGEOS(ptr)
end
