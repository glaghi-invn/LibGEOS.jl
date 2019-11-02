@testset "Geo interface" begin
    pt = LibGEOS.Point(1.0,2.0)
    # @test GeoInterphase.coordinates(pt) ≈ [1,2] atol=1e-5
    @test GeoInterphase.geomtype(pt) == GeoInterphase.Point()

    pt = LibGEOS.Point(1, 2)
    # @test GeoInterphase.coordinates(pt) ≈ [1,2] atol=1e-5
    @test GeoInterphase.geomtype(pt) == GeoInterphase.Point()


    pt = LibGEOS.readgeom("POINT EMPTY")
    # @test GeoInterphase.coordinates(pt) ≈ Float64[] atol=1e-5
    @test GeoInterphase.geomtype(pt) == GeoInterphase.Point()

    mpt = LibGEOS.readgeom("MULTIPOINT(0 0, 10 0, 10 10, 11 10)")
    # @test GeoInterphase.coordinates(mpt) == Vector{Float64}[[0,0],[10,0],[10,10],[11,10]]
    @test GeoInterphase.geomtype(mpt) == GeoInterphase.MultiPoint()

    coords = Vector{Float64}[[8,1],[9,1],[9,2],[8,2]]
    ls = LibGEOS.LineString(coords)
    # @test GeoInterphase.coordinates(ls) == coords
    @test GeoInterphase.geomtype(ls) == GeoInterphase.LineString()

    ls = LibGEOS.readgeom("LINESTRING EMPTY")
    # @test GeoInterphase.coordinates(ls) == []
    @test GeoInterphase.geomtype(ls) == GeoInterphase.LineString()

    mls = LibGEOS.readgeom("MULTILINESTRING ((5 0, 10 0), (0 0, 5 0))")
    # @test GeoInterphase.coordinates(mls) == [[[5,0],[10,0]],[[0,0],[5,0]]]
    @test GeoInterphase.geomtype(mls) == GeoInterphase.MultiLineString()

    coords = Vector{Float64}[[8,1],[9,1],[9,2],[8,2],[8,1]]
    lr = LibGEOS.LinearRing(coords)
    # @test GeoInterphase.coordinates(lr) == coords
    @test GeoInterphase.geomtype(lr) == GeoInterphase.LineString()

    coords = Vector{Vector{Float64}}[Vector{Float64}[[0,0],[10,0],[10,10],[0,10],[0,0]],
                                     Vector{Float64}[[1,8],[2,8],[2,9],[1,9],[1,8]],
                                     Vector{Float64}[[8,1],[9,1],[9,2],[8,2],[8,1]]]
    polygon = LibGEOS.Polygon(coords)
    # @test GeoInterphase.coordinates(polygon) == coords
    @test GeoInterphase.geomtype(polygon) == GeoInterphase.Polygon()

    polygon = LibGEOS.readgeom("POLYGON EMPTY")
    # @test GeoInterphase.coordinates(polygon) == [[]]
    @test GeoInterphase.geomtype(polygon) == GeoInterphase.Polygon()

    multipolygon = LibGEOS.readgeom("MULTIPOLYGON(((0 0,0 10,10 10,10 0,0 0)))")
    # @test GeoInterphase.coordinates(multipolygon) == Vector{Vector{Vector{Float64}}}[Vector{Vector{Float64}}[Vector{Float64}[[0,0],[0,10],[10,10],[10,0],[0,0]]]]
    @test GeoInterphase.geomtype(multipolygon) == GeoInterphase.MultiPolygon()

    geomcollection = LibGEOS.readgeom("GEOMETRYCOLLECTION (POLYGON ((8 2, 10 10, 8.5 1, 8 2)), POLYGON ((7 8, 10 10, 8 2, 7 8)), POLYGON ((3 8, 10 10, 7 8, 3 8)), POLYGON ((2 2, 8 2, 8.5 1, 2 2)), POLYGON ((2 2, 7 8, 8 2, 2 2)), POLYGON ((2 2, 3 8, 7 8, 2 2)), POLYGON ((0.5 9, 10 10, 3 8, 0.5 9)), POLYGON ((0.5 9, 3 8, 2 2, 0.5 9)), POLYGON ((0 0, 2 2, 8.5 1, 0 0)), POLYGON ((0 0, 0.5 9, 2 2, 0 0)))")
    # collection = GeoInterphase.geometries(geomcollection)
    coords = Vector{Vector{Vector{Float64}}}[Vector{Vector{Float64}}[Vector{Float64}[[8.0,2.0],[10.0,10.0],[8.5,1.0],[8.0,2.0]]],
                                             Vector{Vector{Float64}}[Vector{Float64}[[7.0,8.0],[10.0,10.0],[8.0,2.0],[7.0,8.0]]],
                                             Vector{Vector{Float64}}[Vector{Float64}[[3.0,8.0],[10.0,10.0],[7.0,8.0],[3.0,8.0]]],
                                             Vector{Vector{Float64}}[Vector{Float64}[[2.0,2.0],[ 8.0, 2.0],[8.5,1.0],[2.0,2.0]]],
                                             Vector{Vector{Float64}}[Vector{Float64}[[2.0,2.0],[ 7.0, 8.0],[8.0,2.0],[2.0,2.0]]],
                                             Vector{Vector{Float64}}[Vector{Float64}[[2.0,2.0],[ 3.0, 8.0],[7.0,8.0],[2.0,2.0]]],
                                             Vector{Vector{Float64}}[Vector{Float64}[[0.5,9.0],[10.0,10.0],[3.0,8.0],[0.5,9.0]]],
                                             Vector{Vector{Float64}}[Vector{Float64}[[0.5,9.0],[ 3.0, 8.0],[2.0,2.0],[0.5,9.0]]],
                                             Vector{Vector{Float64}}[Vector{Float64}[[0.0,0.0],[ 2.0, 2.0],[8.5,1.0],[0.0,0.0]]],
                                             Vector{Vector{Float64}}[Vector{Float64}[[0.0,0.0],[ 0.5, 9.0],[2.0,2.0],[0.0,0.0]]]]
    # @test map(GeoInterphase.coordinates,collection) == coords
    @test GeoInterphase.geomtype(geomcollection) == GeoInterphase.GeometryCollection()

    geomcollection = LibGEOS.readgeom("GEOMETRYCOLLECTION(MULTIPOINT(0 0, 0 0, 1 1),LINESTRING(1 1, 2 2, 2 2, 0 0),POLYGON((5 5, 0 0, 0 2, 2 2, 5 5)))")
    # collection = GeoInterphase.geometries(geomcollection)
    coords = Vector[Vector{Float64}[[0.0,0.0],[0.0,0.0],[1.0,1.0]],
                    Vector{Float64}[[1.0,1.0],[2.0,2.0],[2.0,2.0],[0.0,0.0]],
                    Vector{Vector{Float64}}[Vector{Float64}[[5.0,5.0],[0.0,0.0],[0.0,2.0],[2.0,2.0],[5.0,5.0]]]]
    geomtypes = [GeoInterphase.MultiPoint(), GeoInterphase.LineString(), GeoInterphase.Polygon()]
    # for (i,item) in enumerate(collection)
    #     @test GeoInterphase.coordinates(item) == coords[i]
    #     @test GeoInterphase.geomtype(item) == geomtypes[i]
    # end
    @test GeoInterphase.geomtype(geomcollection) == GeoInterphase.GeometryCollection()

    geomcollection = LibGEOS.readgeom("GEOMETRYCOLLECTION EMPTY")
    # collection = GeoInterphase.geometries(geomcollection)
    # @test length(collection) == 0
    @test GeoInterphase.geomtype(geomcollection) == GeoInterphase.GeometryCollection()
end
