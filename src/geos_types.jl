# abstract type Geometry <: AbstractVector{Float64} end
abstract type Geometry end

mutable struct Point <: Geometry
    ptr::GEOSGeom

    function Point(ptr::GEOSGeom)
        point = new(ptr)
        finalizer(destroyGeom, point)
        point
    end
    Point(coords::Vector{Float64}) = Point(createPoint(coords))
    Point(x::Real, y::Real) = Point(createPoint(x,y))
    Point(x::Real, y::Real, z::Real) = Point(createPoint(x,y,z))
end

mutable struct MultiPoint <: Geometry
    ptr::GEOSGeom

    function MultiPoint(ptr::GEOSGeom)
        multipoint = new(ptr)
        finalizer(destroyGeom, multipoint)
        multipoint
    end
    MultiPoint(multipoint::Vector{Vector{Float64}}) = MultiPoint(createCollection(GEOS_MULTIPOINT, GEOSGeom[createPoint(coords) for coords in multipoint]))
end

mutable struct LineString <: Geometry
    ptr::GEOSGeom

    function LineString(ptr::GEOSGeom)
        line = new(ptr)
        finalizer(destroyGeom, line)
        line
    end
    LineString(line::Vector{Vector{Float64}}) = LineString(createLineString(line))
end

mutable struct MultiLineString <: Geometry
    ptr::GEOSGeom

    function MultiLineString(ptr::GEOSGeom)
        multiline = new(ptr)
        finalizer(destroyGeom, multiline)
        multiline
    end
    MultiLineString(multiline::Vector{Vector{Vector{Float64}}}) = MultiLineString(createCollection(GEOS_MULTILINESTRING, GEOSGeom[createLineString(coords) for coords in multiline]))
end

mutable struct LinearRing <: Geometry
    ptr::GEOSGeom

    function LinearRing(ptr::GEOSGeom)
        ring = new(ptr)
        finalizer(destroyGeom, ring)
        ring
    end
    LinearRing(ring::Vector{Vector{Float64}}) = LinearRing(createLinearRing(ring))
end

mutable struct Polygon <: Geometry
    ptr::GEOSGeom

    function Polygon(ptr::GEOSGeom)
        polygon = new(ptr)
        finalizer(destroyGeom, polygon)
        polygon
    end
    function Polygon(coords::Vector{Vector{Vector{Float64}}})
        exterior = createLinearRing(coords[1])
        interiors = GEOSGeom[createLinearRing(lr) for lr in coords[2:end]]
        polygon = new(createPolygon(exterior,interiors))
        finalizer(destroyGeom, polygon)
        polygon
    end
end

mutable struct MultiPolygon <: Geometry
    ptr::GEOSGeom

    function MultiPolygon(ptr::GEOSGeom)
        multipolygon = new(ptr)
        finalizer(destroyGeom, multipolygon)
        multipolygon
    end
    MultiPolygon(multipolygon::Vector{Vector{Vector{Vector{Float64}}}}) =
        MultiPolygon(createCollection(GEOS_MULTIPOLYGON,
                                      GEOSGeom[createPolygon(createLinearRing(coords[1]),
                                                             GEOSGeom[createLinearRing(c) for c in coords[2:end]])
                                               for coords in multipolygon]))
end

mutable struct GeometryCollection <: Geometry
    ptr::GEOSGeom

    function GeometryCollection(ptr::GEOSGeom)
        geometrycollection = new(ptr)
        finalizer(destroyGeom, geometrycollection)
        geometrycollection
    end
    GeometryCollection(collection::Vector{GEOSGeom}) = GeometryCollection(createCollection(GEOS_GEOMETRYCOLLECTION, collection))
end

for geom in (:Point, :MultiPoint, :LineString, :MultiLineString, :LinearRing, :Polygon, :MultiPolygon, :GeometryCollection)
    @eval begin
        function destroyGeom(obj::$geom, context::GEOSContext = _context)
            destroyGeom(obj.ptr, context)
            obj.ptr = C_NULL
        end
    end
end

mutable struct PreparedGeometry{G <: Geometry} <: Geometry
    ptr::Ptr{GEOSPreparedGeometry}
    ownedby::G
end

function destroyGeom(obj::PreparedGeometry, context::GEOSContext = _context)
    destroyPreparedGeom(obj.ptr, context)
    obj.ptr = C_NULL
end
