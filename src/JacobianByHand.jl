"""
First step in camera projection
"""
function P1(r, t, X)
  θ = norm(r)
  k = r / θ
  return cos(θ) * X + sin(θ) * cross(k, X) + (1 - cos(θ)) * dot(k, X) * k + t
end

"""
First step in camera projection
"""
function P1!(r, t, X, P1_vec, P1_cross)
  θ = norm(r)
  P1_vec .= r ./ θ
  P1_cross[1] = P1_vec[2]*X[3]-P1_vec[3]*X[2]
  P1_cross[2] = P1_vec[3]*X[1]-P1_vec[1]*X[3]
  P1_cross[3] = P1_vec[1]*X[2]-P1_vec[2]*X[1]
  P1_vec .= cos(θ) .* X .+ sin(θ) .* P1_cross .+ (1 - cos(θ)) .* dot(P1_vec, X) .* P1_vec .+ t
end

"""
Second step in camera projection
"""
function P2(X)
  if X[3] == 0
    return NaN * X[1:2]
  else
    return -X[1:2] / X[3]
  end
end

"""
Second step in camera projection
"""
function P2!(X,P2_vec)
  if X[3] == 0
    @views P2_vec .= NaN .* X[1:2]
  else
    @views P2_vec .= .-X[1:2] ./ X[3]
  end
end

"""
Jacobian of the first step of the projection
"""
function JP1!(JP1, r, X, k)
  θ = norm(r)
  c, s = cos(θ), sin(θ)
  k .= r ./ θ
  x, y, z = X
  kx, ky, kz = k
  d = dot(k, X)

  JP1[1, 1] = c + (1 - c) * kx^2
  JP1[1, 2] = -s * kz + (1 - c) * ky * kx
  JP1[1, 3] = s * ky + (1 - c) * kz * kx
  JP1[1, 4] =
    -s * x * kx +
    c * kx * (ky * z - kz * y) +
    s / θ * (-ky * kx * z + kz * kx * y) +
    s * kx^2 * d +
    (1 - c) / θ * (2 * x * kx * (1 - kx^2) + y * ky * (1 - 2 * kx^2) + z * kz * (1 - 2 * kx^2))
  JP1[1, 5] =
    -s * x * ky +
    c * ky * (ky * z - kz * y) +
    s / θ * ((1 - ky^2) * z + kz * ky * y) +
    s * kx * ky * d +
    (1 - c) / θ * (-2 * x * kx^2 * ky + y * kx * (1 - 2 * ky^2) - 2 * z * kx * ky * kz)
  JP1[1, 6] =
    -s * x * kz +
    c * kz * (ky * z - kz * y) +
    s / θ * (-ky * kz * z - (1 - kz^2) * y) +
    s * kx * kz * d +
    (1 - c) / θ * (-2 * x * kx^2 * kz - 2 * y * kx * ky * kz + z * kx * (1 - 2 * kz^2))

  JP1[2, 1] = s * kz + (1 - c) * ky * kx
  JP1[2, 2] = c + (1 - c) * ky^2
  JP1[2, 3] = -s * kx + (1 - c) * ky * kz
  JP1[2, 4] =
    -s * y * kx +
    c * kx * (kz * x - kx * z) +
    s / θ * (-kz * kx * x - (1 - kx^2) * z) +
    s * kx * ky * d +
    (1 - c) / θ * (x * ky * (1 - 2 * kx^2) - 2 * y * kx * ky^2 - 2 * z * kx * ky * kz)
  JP1[2, 5] =
    -s * y * ky +
    c * ky * (kz * x - kx * z) +
    s / θ * (-kz * ky * x + kx * ky * z) +
    s * ky^2 * d +
    (1 - c) / θ * (x * kx * (1 - 2 * ky^2) + 2 * y * ky * (1 - ky^2) + z * kz * (1 - 2 * ky^2))
  JP1[2, 6] =
    -s * y * kz +
    c * kz * (kz * x - kx * z) +
    s / θ * ((1 - kz^2) * x + kx * kz * z) +
    s * kz * ky * d +
    (1 - c) / θ * (-2 * x * kx * ky * kz - 2 * y * ky^2 * kz + z * ky * (1 - 2 * kz^2))

  JP1[3, 1] = -s * ky + (1 - c) * kx * kz
  JP1[3, 2] = s * kx + (1 - c) * ky * kz
  JP1[3, 3] = c + (1 - c) * kz^2
  JP1[3, 4] =
    -s * z * kx +
    c * kx * (kx * y - ky * x) +
    s / θ * ((1 - kx^2) * y + kx * ky * x) +
    s * kx * kz * d +
    (1 - c) / θ * (x * kz * (1 - 2 * kx^2) - 2 * y * kx * ky * kz - 2 * z * kx * kz^2)
  JP1[3, 5] =
    -s * z * ky +
    c * ky * (kx * y - ky * x) +
    s / θ * (-kx * ky * y - (1 - ky^2) * x) +
    s * ky * kz * d +
    (1 - c) / θ * (-2 * x * kx * ky * kz + y * kz * (1 - 2 * ky^2) - 2 * z * ky * kz^2)
  JP1[3, 6] =
    -s * z * kz +
    c * kz * (kx * y - ky * x) +
    s / θ * (-kx * kz * y + kz * ky * x) +
    s * kz^2 * d +
    (1 - c) / θ * (x * kx * (1 - 2 * kz^2) + y * ky * (1 - 2 * kz^2) + 2 * z * kz * (1 - kz^2))
  return JP1
end

"""
Jacobian of the second step of the projection
"""
function JP2!(JP2, X)
  x, y, z = X
  if z == 0
    JP2[1, 1] = NaN
  else
    JP2[1, 1] = -1 / z
    JP2[1, 3] = x / z^2

    JP2[2, 2] = JP2[1, 1]
    JP2[2, 3] = y / z^2
  end
  return JP2
end

"""
Jacobian of the third step of the projection
"""
function JP3!(JP3, X, f, k1, k2)
  x, y = X
  norm2 = dot(X, X)
  norm4 = norm2^2
  r = 1 + k1 * norm2 + k2 * norm4

  JP3[1, 1] = f * r + f * (2 * k1 * x + k2 * (4 * x^3 + 4 * x * y^2)) * x
  JP3[1, 2] = f * (2 * k1 * y + k2 * (4 * y^3 + 4 * y * x^2)) * x
  JP3[1, 3] = f * norm2 * x
  JP3[1, 4] = f * norm4 * x
  JP3[1, 5] = r * x

  JP3[2, 1] = f * (2 * k1 * x + k2 * (4 * x^3 + 4 * x * y^2)) * y
  JP3[2, 2] = f * r + f * (2 * k1 * y + k2 * (4 * y^3 + 4 * y * x^2)) * y
  JP3[2, 3] = f * norm2 * y
  JP3[2, 4] = f * norm4 * y
  JP3[2, 5] = r * y
  return JP3
end
