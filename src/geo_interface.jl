# TODO add back constructors for geometries using the GeoInterface

#=
GeoInterfaceRFC.coordinates(obj::Point) = isEmpty(obj.ptr) ? Float64[] : getCoordinates(getCoordSeq(obj.ptr), 1)
GeoInterfaceRFC.coordinates(obj::LineString) = getCoordinates(getCoordSeq(obj.ptr))
GeoInterfaceRFC.coordinates(obj::LinearRing) = getCoordinates(getCoordSeq(obj.ptr))

function GeoInterfaceRFC.coordinates(polygon::Polygon)
    exterior = getCoordinates(getCoordSeq(exteriorRing(polygon.ptr)))
    interiors = [getCoordinates(getCoordSeq(ring)) for ring in interiorRings(polygon.ptr)]
    if length(interiors) == 0
        return Vector{Vector{Float64}}[exterior]
    else
        return [Vector{Vector{Float64}}[exterior]; interiors]
    end
end

GeoInterfaceRFC.coordinates(multipoint::MultiPoint) = Vector{Float64}[getCoordinates(getCoordSeq(geom),1) for geom in getGeometries(multipoint.ptr)]
GeoInterfaceRFC.coordinates(multiline::MultiLineString) = Vector{Vector{Float64}}[getCoordinates(getCoordSeq(geom)) for geom in getGeometries(multiline.ptr)]
function GeoInterfaceRFC.coordinates(multipolygon::MultiPolygon)
    geometries = getGeometries(multipolygon.ptr)
    coords = Array{Vector{Vector{Vector{Float64}}}}(undef, length(geometries))
    for (i,geom) in enumerate(getGeometries(multipolygon.ptr))
        exterior = getCoordinates(getCoordSeq(exteriorRing(geom)))
        interiors = [getCoordinates(getCoordSeq(ring)) for ring in interiorRings(geom)]
        coords[i] = [Vector{Vector{Float64}}[exterior]; interiors]
    end
    coords
end

function GeoInterfaceRFC.geometries(obj::GeometryCollection)
    collection = GeoInterfaceRFC.AbstractGeometry[]
    sizehint!(collection, numGeometries(obj.ptr))
    for geom in getGeometries(obj.ptr)
        if geomTypeId(geom) == GEOS_POINT
            push!(collection, Point(cloneGeom(geom)))
        elseif geomTypeId(geom) == GEOS_LINESTRING
            push!(collection, LineString(cloneGeom(geom)))
        elseif geomTypeId(geom) == GEOS_LINEARRING
            push!(collection, LinearRing(cloneGeom(geom)))
        elseif geomTypeId(geom) == GEOS_POLYGON
            push!(collection, Polygon(cloneGeom(geom)))
        elseif geomTypeId(geom) == GEOS_MULTIPOINT
            push!(collection, MultiPoint(cloneGeom(geom)))
        elseif geomTypeId(geom) == GEOS_MULTILINESTRING
            push!(collection, MultiLineString(cloneGeom(geom)))
        elseif geomTypeId(geom) == GEOS_MULTIPOLYGON
            push!(collection, MultiPolygon(cloneGeom(geom)))
        else
            @assert geomTypeId(geom) == GEOS_GEOMETRYCOLLECTION
            push!(collection, GeometryCollection(cloneGeom(geom)))
        end
    end
    collection
end
=#

GeoInterfaceRFC.geomtype(g::Point) = GeoInterfaceRFC.Point()
GeoInterfaceRFC.geomtype(g::LineString) = GeoInterfaceRFC.LineString()
GeoInterfaceRFC.geomtype(g::Polygon) = GeoInterfaceRFC.Polygon()
GeoInterfaceRFC.geomtype(g::MultiPoint) = GeoInterfaceRFC.MultiPoint()
GeoInterfaceRFC.geomtype(g::MultiLineString) = GeoInterfaceRFC.MultiLineString()
GeoInterfaceRFC.geomtype(g::MultiPolygon) = GeoInterfaceRFC.MultiPolygon()
GeoInterfaceRFC.geomtype(g::GeometryCollection) = GeoInterfaceRFC.GeometryCollection()
GeoInterfaceRFC.geomtype(g::LinearRing) = GeoInterfaceRFC.LineString()
# TODO handle PreparedGeometry


function GeoInterfaceRFC.ncoord(g::Geometry)
    cs = getCoordSeq(g.ptr)
    getDimensions(cs)
end

function GeoInterfaceRFC.getcoord(g::Point, i::Int)
    cs = getCoordSeq(g.ptr)
    if i == 1
        getX(cs, 1)
    elseif i == 2
        geYX(cs, 1)
    elseif i == 3
        getZ(cs, 1)
    else
        throw(ArgumentError("GEOS only supports 2 and 3 dimensional points"))
    end
end

function GeoInterfaceRFC.npoint(g::LineString)
    numPoints(g)
end

## came up to here

function GeoInterfaceRFC.getpoint(g::LineString, i::Int)
    cs = getCoordSeq(g.ptr)
    Point(g[i])
end

# TODO what to return for length 0 and 1?
# TODO should this be an approximate equals for floating point?
function GeoInterfaceRFC.isclosed(g::LineString, i::Int)
    cs = getCoordSeq(g.ptr)
    first(g) == last(g)
end

# TODO this should return a "LineString" according to GeoInterfaceRFC, but this cannot directly
# be identified as such, is that a problem?

function GeoInterfaceRFC.getexterior(g::Polygon)
    cs = getCoordSeq(g.ptr)
    LineString(first(g))
end

function GeoInterfaceRFC.nhole(g::Polygon)
    cs = getCoordSeq(g.ptr)
    length(g) - 1
end

function GeoInterfaceRFC.gethole(g::Polygon, i::Int)
    cs = getCoordSeq(g.ptr)
    LineString(g[i + 1])
end

function GeoInterfaceRFC.npoint(g::MultiPoint)
    cs = getCoordSeq(g.ptr)
    length(g)
end

function GeoInterfaceRFC.getpoint(g::MultiPoint, i::Int)
    cs = getCoordSeq(g.ptr)
    Point(g[i])
end

function GeoInterfaceRFC.nlinestring(g::MultiLineString)
    cs = getCoordSeq(g.ptr)
    length(g)
end

function GeoInterfaceRFC.getlinestring(g::MultiLineString, i::Int)
    cs = getCoordSeq(g.ptr)
    LineString(g[i])
end

function GeoInterfaceRFC.npolygon(g::MultiPolygon)
    cs = getCoordSeq(g.ptr)
    length(g)
end

function GeoInterfaceRFC.getpolygon(g::MultiPolygon, i::Int)
    cs = getCoordSeq(g.ptr)
    LineString(g[i])
end

function GeoInterfaceRFC.ngeom(g::GeometryCollection)
    cs = getCoordSeq(g.ptr)
    length(g)
end

function GeoInterfaceRFC.getgeom(g::GeometryCollection, i::Int)
    cs = getCoordSeq(g.ptr)
    geometry(g[i])
end
