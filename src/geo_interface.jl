# TODO add back constructors for geometries using the GeoInterface

#=
GeoInterphase.coordinates(obj::Point) = isEmpty(obj.ptr) ? Float64[] : getCoordinates(getCoordSeq(obj.ptr), 1)
GeoInterphase.coordinates(obj::LineString) = getCoordinates(getCoordSeq(obj.ptr))
GeoInterphase.coordinates(obj::LinearRing) = getCoordinates(getCoordSeq(obj.ptr))

function GeoInterphase.coordinates(polygon::Polygon)
    exterior = getCoordinates(getCoordSeq(exteriorRing(polygon.ptr)))
    interiors = [getCoordinates(getCoordSeq(ring)) for ring in interiorRings(polygon.ptr)]
    if length(interiors) == 0
        return Vector{Vector{Float64}}[exterior]
    else
        return [Vector{Vector{Float64}}[exterior]; interiors]
    end
end

GeoInterphase.coordinates(multipoint::MultiPoint) = Vector{Float64}[getCoordinates(getCoordSeq(geom),1) for geom in getGeometries(multipoint.ptr)]
GeoInterphase.coordinates(multiline::MultiLineString) = Vector{Vector{Float64}}[getCoordinates(getCoordSeq(geom)) for geom in getGeometries(multiline.ptr)]
function GeoInterphase.coordinates(multipolygon::MultiPolygon)
    geometries = getGeometries(multipolygon.ptr)
    coords = Array{Vector{Vector{Vector{Float64}}}}(undef, length(geometries))
    for (i,geom) in enumerate(getGeometries(multipolygon.ptr))
        exterior = getCoordinates(getCoordSeq(exteriorRing(geom)))
        interiors = [getCoordinates(getCoordSeq(ring)) for ring in interiorRings(geom)]
        coords[i] = [Vector{Vector{Float64}}[exterior]; interiors]
    end
    coords
end

function GeoInterphase.geometries(obj::GeometryCollection)
    collection = GeoInterphase.AbstractGeometry[]
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

GeoInterphase.geomtype(g::Point) = GeoInterphase.Point()
GeoInterphase.geomtype(g::LineString) = GeoInterphase.LineString()
GeoInterphase.geomtype(g::Polygon) = GeoInterphase.Polygon()
GeoInterphase.geomtype(g::MultiPoint) = GeoInterphase.MultiPoint()
GeoInterphase.geomtype(g::MultiLineString) = GeoInterphase.MultiLineString()
GeoInterphase.geomtype(g::MultiPolygon) = GeoInterphase.MultiPolygon()
GeoInterphase.geomtype(g::GeometryCollection) = GeoInterphase.GeometryCollection()
GeoInterphase.geomtype(g::LinearRing) = GeoInterphase.LineString()
# TODO handle PreparedGeometry


function GeoInterphase.ncoord(g::Geometry)
    cs = getCoordSeq(g.ptr)
    getDimensions(cs)
end

function GeoInterphase.getcoord(g::Point, i::Int)
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

function GeoInterphase.npoint(g::LineString)
    numPoints(g)
end

## came up to here

function GeoInterphase.getpoint(g::LineString, i::Int)
    cs = getCoordSeq(g.ptr)
    Point(g[i])
end

# TODO what to return for length 0 and 1?
# TODO should this be an approximate equals for floating point?
function GeoInterphase.isclosed(g::LineString, i::Int)
    cs = getCoordSeq(g.ptr)
    first(g) == last(g)
end

# TODO this should return a "LineString" according to GeoInterphase, but this cannot directly
# be identified as such, is that a problem?

function GeoInterphase.getexterior(g::Polygon)
    cs = getCoordSeq(g.ptr)
    LineString(first(g))
end

function GeoInterphase.nhole(g::Polygon)
    cs = getCoordSeq(g.ptr)
    length(g) - 1
end

function GeoInterphase.gethole(g::Polygon, i::Int)
    cs = getCoordSeq(g.ptr)
    LineString(g[i + 1])
end

function GeoInterphase.npoint(g::MultiPoint)
    cs = getCoordSeq(g.ptr)
    length(g)
end

function GeoInterphase.getpoint(g::MultiPoint, i::Int)
    cs = getCoordSeq(g.ptr)
    Point(g[i])
end

function GeoInterphase.nlinestring(g::MultiLineString)
    cs = getCoordSeq(g.ptr)
    length(g)
end

function GeoInterphase.getlinestring(g::MultiLineString, i::Int)
    cs = getCoordSeq(g.ptr)
    LineString(g[i])
end

function GeoInterphase.npolygon(g::MultiPolygon)
    cs = getCoordSeq(g.ptr)
    length(g)
end

function GeoInterphase.getpolygon(g::MultiPolygon, i::Int)
    cs = getCoordSeq(g.ptr)
    LineString(g[i])
end

function GeoInterphase.ngeom(g::GeometryCollection)
    cs = getCoordSeq(g.ptr)
    length(g)
end

function GeoInterphase.getgeom(g::GeometryCollection, i::Int)
    cs = getCoordSeq(g.ptr)
    geometry(g[i])
end
