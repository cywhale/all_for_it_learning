// run in cesium sandcastle: 
// https://sandcastle.cesium.com/#c=rVfbUuM4EP0VFS9xBiIzl4clyVALDAtUcSvILFU7TFGK3YkFtuSR5ITMFv++Lcl2bBKy8zB5SSz1OepudZ92ZkyRGYc5KPKZCJiTI9C8yOjfbi2434rc85EUhnEB6n6rO7gXM0TNQZsdomVhkh0CzD4IqUxSbhsp0zGzrLGMigyEoVMwxynYn4eLszjolCadijFiGSiGCO8Q9c+4eS8mhYgMl4LEYCAy/0iZncMM0iDm2jARQZf8ey8IflIwREcgYMnjHgfLbcNTuFZyxmMXtdum01SOgT7oQk1YBLRp04D+KFhsFFjypgV9qDYatrFicy6mh8VkAuoU+DQxzdgwZE0Tt9wAaQ1fQMiMC2akep0LOlGFNng9bTOXIsswQUhgaVKbHETvDsqfw8/k/V75sL1dZ6s6NmPPJyAzMIpHx0q5k1sB4t25hF+wZ54VWds4cLTdQZsTSp5glfzduuR0SUjq+0STdoxNdj4hgWcf1jdCM+/ZbYQP4jbHS3RntUK1HwWmUMJnosH54n++VKkszUSRWiu3HIaJMbnuh+GUa4p+Rk/wHCVMTIFGMgt/FNgSWKQ6fP9hb2/3Y+h7p/cx7tmyVRgJhtwzCfQylvd0xFLoyYlbcNcc91wVYjeUl57K6IlKMeL4xeL4eIa9c44ZwoJVQd0TQR2j7Ulb0bYp8Xtvb6+M0PanbXDboPjd8zt+LwzJ0cHX0dnVZZ8cROizRi/JQ674jBkg2JmcjVPQhGskMEROJjziLE0XRBd5jpQQEybimq3+YGDk4PoMG1uQsQL2RJhBywWWVgZkzk2CjpI5UzYv1OOddmDl6ZG8AeE7tNnHmxqVPrSQh4sRPOMtwpEshKnjtdVTqlwMExS1OGjBuq2Ssf6IIjtQii102RW1KU1BTJ3kVeauAy3m0XffI5ZoDR+Q7e3HlYK01lUVr5zw7fH7oG2+xv0a3V0hb4QwKvlr61XvW1HYHuY+Cu6jcAw2CL72nOoshQqNTZFC87Bv/DutNwbrwWX5XjCTUGyWwI+YGkXtc/cNbFXzNbicTEu0W3gLXjaIR7PnwA+0Jdg+v4WtuqoGu4Um2i2sg7+0l17e1iObWB0pZqLkppHfxsiul4PqpOoyVsYIqlVeGLBDfola02WQpjzXksc7S8deO9E8LJd65Sxc41amGmYRU0ZOFcsTHqF96f9xdRi9O7n94xO1VrjDxEgeNQABEjbPTKrJ2mRtD1ZrVk3E1y8Q3rBJOBbxbZ6AsukNw9K5Q5SQGFXK7+Acltm15MLopjsrhbG8nDa+dUM5f4b0lv8EF4PLGU7b62o1qP3ZaQtha4Te8diW3NsGp604w7AsAdvWYxRZOfF+aBRtFGmp+BTnbkp8BQBheQ5M4a4kdkDVFYkOnolrj8RR/wHndu0vVSzmhbZzvY4Rzw/flZIEc5dCK3n0ofQcBxxWC2oTjrug1pjc2vWbmlMT9ls+NOo0kqlU/Sr/R/aJntwcH182bPzl3wDmB/Clo7Y+ba/To/ODi+uH0dXDyc3V18svFUHVo90BeRfa38sB46Rsn+zt7raksnzlpVzgBD8dXZxj8J1zGTE3yO10fRJyLminvKcXvADM/maGdvF17vDoPumQ7Soap0tGfoGpFWLnWhef/8KMxcGnLhp2hmMV7iPkFdWtlcxNXF5Tf43smG32y0nsr1FdWj3dxOUF99fIMvtupkkOZSt63mVXNpDkFbTSthKC6rfB2BebN12jVZugP1GuvIJ5uBezDYBez0mBU/8+6fU6m4z/r2AsCf2dVeMIf2fpOMLfWT+OcKWIBqQeyi9WSbd2tobaLFLYr/j/5Jl9ISaFSgNKQwNZnuJLtA7HBf5ZMDTS9bAYhk3oMOYzwuPPa/5wkyhlWuPOBP+L2Iq839ofhmi/Ak0lszPmagYqZQtrlrzfP/eLlNJhiI/rkaWqvGL+Dw
var viewer = new Cesium.Viewer("cesiumContainer");
var west, south, east, north;
var toolbar = document.getElementById('toolbar');
var camera = viewer.camera;

//https://gist.github.com/ezze/d57e857a287677c9b43b5a6a43243b14
function detectZoomLevel(distance) {
    let scene = viewer.scene;
    let tileProvider = scene.globe._surface.tileProvider;
    let quadtree = tileProvider._quadtree;
    let drawingBufferHeight = viewer.canvas.height;
    let sseDenominator = viewer.camera.frustum.sseDenominator;

    for (let level = 0; level <= 19; level++) {
        let maxGeometricError = tileProvider.getLevelMaximumGeometricError(level);
        let error = (maxGeometricError * drawingBufferHeight) / (distance * sseDenominator);
        if (error < quadtree.maximumScreenSpaceError) {
            return level;
        }
    }

    return null;
}

//https://gis.stackexchange.com/questions/129903/cesium-3d-determining-the-map-scale-of-the-viewed-globe
viewer.clock.onTick.addEventListener(function () {
    west = south = 999;
    east = north = -999;

    // CAUTION: Accessing _private variables is not officially supported and
    //          the API can break at any time without warning.
    var tilesToRender = viewer.scene.globe._surface.tileProvider._tilesToRenderByTextureCount;

    if (Cesium.defined(tilesToRender)) {
        var numArrays = tilesToRender.length;
        for (var j = 0; j < numArrays; ++j) {
            var quadtrees = tilesToRender[j];
            if (Cesium.defined(quadtrees)) {
                var numTrees = quadtrees.length;
                for (let i = 0; i < numTrees; ++i) {
                    var rectangle = quadtrees[i].rectangle;
                    west = Math.min(west, rectangle.west);
                    south = Math.min(south, rectangle.south);
                    east = Math.max(east, rectangle.east);
                    north = Math.max(north, rectangle.north);
                }
            }
        }
    }

    var scratchRectangle = new Cesium.Rectangle();
    var rect = viewer.camera.computeViewRectangle(viewer.scene.globe.ellipsoid,
        scratchRectangle);
    var pos = viewer.camera.position;
    var cartographic = Cesium.Ellipsoid.WGS84.cartesianToCartographic(pos);
    var height = cartographic.height;
    var level = detectZoomLevel(height);
    var bndSphere = //Cesium.BoundingSphere.fromPoints(pos);
                    new Cesium.BoundingSphere();
    var pixelSize = camera.getPixelSize(bndSphere, viewer.scene.drawingBufferWidth, viewer.scene.drawingBufferHeight);
    //compute number of pixels that original ellipse appears to be
    var sizeInPixels = (2 * bndSphere.radius) / pixelSize;
/*  var newPoint = t._viewer.entities.add({
      point: {
        pixelSize: sizeInPixels,
        color: Cesium.Color.GREEN,
        heightReference: Cesium.HeightReference.CLAMP_TO_GROUND
      }
    }); */
  
    if (west > 900) {
        toolbar.innerHTML = 'Location not known.';
    } else {
        toolbar.innerHTML =
            'West: ' + Cesium.Math.toDegrees(west).toFixed(4) + '<br/>' +
            'South: ' + Cesium.Math.toDegrees(south).toFixed(4) + '<br/>' +
            'East: ' + Cesium.Math.toDegrees(east).toFixed(4) + '<br/>' +
            'North: ' + Cesium.Math.toDegrees(north).toFixed(4) + '<br/>' +
            'meters per pixel: ' + pixelSize + '<br/>' + 
            'position: ' + pos + '<br/>' + 
            'height: ' + cartographic.height + '<br/>' + 
            'zoom level: ' + level + '<br/>' + 
            '-- view rect: --' + '<br/>' + 
            'West: ' + Cesium.Math.toDegrees(rect.west).toFixed(4) + '<br/>' +
            'South: ' + Cesium.Math.toDegrees(rect.south).toFixed(4) + '<br/>' +
            'East: ' + Cesium.Math.toDegrees(rect.east).toFixed(4) + '<br/>' +
            'North: ' + Cesium.Math.toDegrees(rect.north).toFixed(4); 
    }
});
